"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediaService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = require("@nestjs/axios");
const rxjs_1 = require("rxjs");
let MediaService = class MediaService {
    httpService;
    bunnyApiKey = process.env.BUNNY_API_KEY;
    bunnyLibraryId = process.env.BUNNY_LIBRARY_ID;
    constructor(httpService) {
        this.httpService = httpService;
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