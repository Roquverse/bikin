"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediaService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = require("@nestjs/axios");
const rxjs_1 = require("rxjs");
const cloudinary_1 = require("cloudinary");
const fs = __importStar(require("fs"));
let MediaService = class MediaService {
    constructor(httpService) {
        this.httpService = httpService;
        this.bunnyApiKey = process.env.BUNNY_API_KEY;
        this.bunnyLibraryId = process.env.BUNNY_LIBRARY_ID;
        cloudinary_1.v2.config({
            cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
            api_key: process.env.CLOUDINARY_API_KEY,
            api_secret: process.env.CLOUDINARY_API_SECRET,
        });
    }
    async createVideo(title) {
        if (!this.bunnyApiKey || !this.bunnyLibraryId) {
            throw new common_1.HttpException('Bunny Stream is not configured', common_1.HttpStatus.INTERNAL_SERVER_ERROR);
        }
        try {
            const url = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos`;
            const response = await (0, rxjs_1.lastValueFrom)(this.httpService.post(url, { title }, {
                headers: {
                    AccessKey: this.bunnyApiKey,
                    'Content-Type': 'application/json',
                    Accept: 'application/json',
                },
            }));
            return {
                videoId: response.data.guid,
                message: 'Video created successfully on Bunny Stream. Ready for upload.',
            };
        }
        catch (error) {
            throw new common_1.HttpException(`Failed to create video on Bunny: ${error?.response?.data?.Message || error.message}`, common_1.HttpStatus.BAD_REQUEST);
        }
    }
    async uploadImageToCloudinary(filePath) {
        try {
            if (!process.env.CLOUDINARY_CLOUD_NAME) {
                return `/uploads/${filePath.split('/').pop()}`;
            }
            const result = await cloudinary_1.v2.uploader.upload(filePath, { folder: 'bikin' });
            return result.secure_url;
        }
        catch (e) {
            console.error(e);
            throw new common_1.HttpException('Failed to upload image to Cloudinary', common_1.HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    async uploadVideoToBunny(filePath) {
        if (!this.bunnyApiKey || !this.bunnyLibraryId || !process.env.BUNNY_PULL_ZONE) {
            return `/uploads/${filePath.split('/').pop()}`;
        }
        try {
            const createUrl = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos`;
            const createResponse = await (0, rxjs_1.lastValueFrom)(this.httpService.post(createUrl, { title: `Upload-${Date.now()}` }, {
                headers: {
                    AccessKey: this.bunnyApiKey,
                    'Content-Type': 'application/json',
                    Accept: 'application/json',
                },
            }));
            const videoId = createResponse.data.guid;
            const uploadUrl = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos/${videoId}`;
            const fileStream = fs.createReadStream(filePath);
            await (0, rxjs_1.lastValueFrom)(this.httpService.put(uploadUrl, fileStream, {
                headers: {
                    AccessKey: this.bunnyApiKey,
                    'Content-Type': 'application/octet-stream',
                },
            }));
            return `https://${process.env.BUNNY_PULL_ZONE}/${videoId}/playlist.m3u8`;
        }
        catch (error) {
            console.error(error);
            throw new common_1.HttpException('Failed to upload video to Bunny Stream', common_1.HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    async deleteVideo(videoId) {
        if (!this.bunnyApiKey || !this.bunnyLibraryId) {
            throw new common_1.HttpException('Bunny Stream is not configured', common_1.HttpStatus.INTERNAL_SERVER_ERROR);
        }
        try {
            const url = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos/${videoId}`;
            await (0, rxjs_1.lastValueFrom)(this.httpService.delete(url, {
                headers: {
                    AccessKey: this.bunnyApiKey,
                    Accept: 'application/json',
                },
            }));
            return { success: true, message: 'Video deleted from Bunny Stream' };
        }
        catch (error) {
            throw new common_1.HttpException(`Failed to delete video on Bunny: ${error?.response?.data?.Message || error.message}`, common_1.HttpStatus.BAD_REQUEST);
        }
    }
};
exports.MediaService = MediaService;
exports.MediaService = MediaService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [axios_1.HttpService])
], MediaService);
//# sourceMappingURL=media.service.js.map