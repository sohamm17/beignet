/*
 * Copyright © 2012 Intel Corporation
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * \file image.cpp
 *
 */
#include "image.hpp"
#include "context.hpp"
#include "ocl_common_defines.h"
#include "backend/program.h"

namespace gbe {
namespace ir {

  static uint32_t getInfoOffset4Type(struct ImageInfo *imageInfo, int type)
  {
    switch (type) {
      case GetImageInfoInstruction::WIDTH:              return imageInfo->wSlot;
      case GetImageInfoInstruction::HEIGHT:             return imageInfo->hSlot;
      case GetImageInfoInstruction::DEPTH:              return imageInfo->depthSlot;
      case GetImageInfoInstruction::CHANNEL_DATA_TYPE:  return imageInfo->dataTypeSlot;
      case GetImageInfoInstruction::CHANNEL_ORDER:      return imageInfo->channelOrderSlot;
      default:
        NOT_IMPLEMENTED;
    }
    return 0;
  }

  static uint32_t setInfoOffset4Type(struct ImageInfo *imageInfo, int type, uint32_t offset)
  {
    switch (type) {
      case GetImageInfoInstruction::WIDTH:              imageInfo->wSlot = offset; break;
      case GetImageInfoInstruction::HEIGHT:             imageInfo->hSlot = offset; break;
      case GetImageInfoInstruction::DEPTH:              imageInfo->depthSlot = offset; break;
      case GetImageInfoInstruction::CHANNEL_DATA_TYPE:  imageInfo->dataTypeSlot = offset; break;
      case GetImageInfoInstruction::CHANNEL_ORDER:      imageInfo->channelOrderSlot = offset; break;
      default:
        NOT_IMPLEMENTED;
    }
    return 0;
  }

  void ImageSet::appendInfo(ImageInfoKey key, uint32_t offset)
  {
    map<uint32_t, struct ImageInfo *>::iterator it = indexMap.find(key.index);
    assert(it != indexMap.end());
    struct ImageInfo *imageInfo = it->second;
    setInfoOffset4Type(imageInfo, key.type, offset);
  }

  void ImageSet::clearInfo()
  {
    struct ImageInfo *imageInfo;
    for (map<uint32_t, struct ImageInfo *>::iterator it = indexMap.begin(); it != indexMap.end(); ++it) {
      imageInfo = it->second;
      imageInfo->wSlot = -1;
      imageInfo->hSlot = -1;
      imageInfo->depthSlot = -1;
      imageInfo->dataTypeSlot = -1;
      imageInfo->channelOrderSlot = -1;
    }
  }
  int32_t ImageSet::getInfoOffset(ImageInfoKey key) const
  {
    map<uint32_t, struct ImageInfo *>::const_iterator it = indexMap.find(key.index);
    if (it == indexMap.end())
      return -1;
    struct ImageInfo *imageInfo = it->second;
    return getInfoOffset4Type(imageInfo, key.type);
  }

  uint32_t ImageSet::getIdx(const Register imageReg) const
  {
    map<Register, struct ImageInfo *>::const_iterator it = regMap.find(imageReg);
    GBE_ASSERT(it != regMap.end());
    return it->second->idx;
  }

  void ImageSet::getData(struct ImageInfo *imageInfos) const {
      int id = 0;
      for (map<Register, struct ImageInfo *>::const_iterator it = regMap.begin(); it != regMap.end(); ++it)
        imageInfos[id++] = *(it->second);
  }

  ImageSet::~ImageSet() {
    for (map<Register, struct ImageInfo *>::const_iterator it = regMap.begin(); it != regMap.end(); ++it)
      GBE_DELETE(it->second);
  }

#define OUT_UPDATE_SZ(elt) SERIALIZE_OUT(elt, outs, ret_size)
#define IN_UPDATE_SZ(elt) DESERIALIZE_IN(elt, ins, total_size)

  /*! Implements the serialization. */
  uint32_t ImageSet::serializeToBin(std::ostream& outs) {
    uint32_t ret_size = 0;
    uint32_t sz = 0;

    OUT_UPDATE_SZ(magic_begin);

    sz = regMap.size();
    OUT_UPDATE_SZ(sz);
    for (map<Register, struct ImageInfo *>::const_iterator it = regMap.begin(); it != regMap.end(); ++it) {
      OUT_UPDATE_SZ(it->first);
      OUT_UPDATE_SZ(it->second->arg_idx);
      OUT_UPDATE_SZ(it->second->idx);
      OUT_UPDATE_SZ(it->second->wSlot);
      OUT_UPDATE_SZ(it->second->hSlot);
      OUT_UPDATE_SZ(it->second->depthSlot);
      OUT_UPDATE_SZ(it->second->dataTypeSlot);
      OUT_UPDATE_SZ(it->second->channelOrderSlot);
      OUT_UPDATE_SZ(it->second->dimOrderSlot);
    }

    sz = indexMap.size();
    OUT_UPDATE_SZ(sz);
    for (map<uint32_t, struct ImageInfo *>::iterator it = indexMap.begin(); it != indexMap.end(); ++it) {
      OUT_UPDATE_SZ(it->first);
      OUT_UPDATE_SZ(it->second->arg_idx);
      OUT_UPDATE_SZ(it->second->idx);
      OUT_UPDATE_SZ(it->second->wSlot);
      OUT_UPDATE_SZ(it->second->hSlot);
      OUT_UPDATE_SZ(it->second->depthSlot);
      OUT_UPDATE_SZ(it->second->dataTypeSlot);
      OUT_UPDATE_SZ(it->second->channelOrderSlot);
      OUT_UPDATE_SZ(it->second->dimOrderSlot);
    }

    OUT_UPDATE_SZ(magic_end);
    OUT_UPDATE_SZ(ret_size);

    return ret_size;
  }

  uint32_t ImageSet::deserializeFromBin(std::istream& ins) {
    uint32_t total_size = 0;
    uint32_t magic;
    uint32_t image_map_sz = 0;

    IN_UPDATE_SZ(magic);
    if (magic != magic_begin)
      return 0;

    IN_UPDATE_SZ(image_map_sz); //regMap
    for (uint32_t i = 0; i < image_map_sz; i++) {
      ir::Register reg;
      ImageInfo *img_info = GBE_NEW(struct ImageInfo);;

      IN_UPDATE_SZ(reg);
      IN_UPDATE_SZ(img_info->arg_idx);
      IN_UPDATE_SZ(img_info->idx);
      IN_UPDATE_SZ(img_info->wSlot);
      IN_UPDATE_SZ(img_info->hSlot);
      IN_UPDATE_SZ(img_info->depthSlot);
      IN_UPDATE_SZ(img_info->dataTypeSlot);
      IN_UPDATE_SZ(img_info->channelOrderSlot);
      IN_UPDATE_SZ(img_info->dimOrderSlot);

      regMap.insert(std::make_pair(reg, img_info));
    }

    IN_UPDATE_SZ(image_map_sz); //indexMap
    for (uint32_t i = 0; i < image_map_sz; i++) {
      uint32_t index;
      ImageInfo *img_info = GBE_NEW(struct ImageInfo);;

      IN_UPDATE_SZ(index);
      IN_UPDATE_SZ(img_info->arg_idx);
      IN_UPDATE_SZ(img_info->idx);
      IN_UPDATE_SZ(img_info->wSlot);
      IN_UPDATE_SZ(img_info->hSlot);
      IN_UPDATE_SZ(img_info->depthSlot);
      IN_UPDATE_SZ(img_info->dataTypeSlot);
      IN_UPDATE_SZ(img_info->channelOrderSlot);
      IN_UPDATE_SZ(img_info->dimOrderSlot);

      indexMap.insert(std::make_pair(img_info->idx, img_info));
    }

    IN_UPDATE_SZ(magic);
    if (magic != magic_end)
      return 0;

    uint32_t total_bytes;
    IN_UPDATE_SZ(total_bytes);
    if (total_bytes + sizeof(total_size) != total_size)
      return 0;

    return total_size;
  }

  void ImageSet::printStatus(int indent, std::ostream& outs) {
    using namespace std;
    string spaces = indent_to_str(indent);
    string spaces_nl = indent_to_str(indent + 4);

    outs << spaces << "------------ Begin ImageSet ------------" << "\n";

    outs << spaces_nl  << "  ImageSet Map: [reg, arg_idx, idx, wSlot, hSlot, depthSlot, "
                "dataTypeSlot, channelOrderSlot, dimOrderSlot]\n";
    outs << spaces_nl << "     regMap size: " << regMap.size() << "\n";
    for (map<Register, struct ImageInfo *>::const_iterator it = regMap.begin(); it != regMap.end(); ++it) {
      outs << spaces_nl << "         [" << it->first << ", "
           << it->second->arg_idx << ", "
           << it->second->idx << ", "
           << it->second->wSlot << ", "
           << it->second->hSlot << ", "
           << it->second->depthSlot << ", "
           << it->second->dataTypeSlot << ", "
           << it->second->channelOrderSlot << ", "
           << it->second->dimOrderSlot << "]" << "\n";
   }

   outs << spaces_nl << "  ImageSet Map: [index, arg_idx, idx, wSlot, hSlot, depthSlot, "
           "dataTypeSlot, channelOrderSlot, dimOrderSlot]\n";
   outs << spaces_nl << "     regMap size: " << indexMap.size() << "\n";
   for (map<uint32_t, struct ImageInfo *>::iterator it = indexMap.begin(); it != indexMap.end(); ++it) {
     outs << spaces_nl << "         [" << it->first << ", "
          << it->second->arg_idx << ", "
          << it->second->idx << ", "
          << it->second->wSlot << ", "
          << it->second->hSlot << ", "
          << it->second->depthSlot << ", "
          << it->second->dataTypeSlot << ", "
          << it->second->channelOrderSlot << ", "
          << it->second->dimOrderSlot << ", " << "\n";
   }

   outs << spaces << "------------- End ImageSet -------------" << "\n";
  }

#ifdef GBE_COMPILER_AVAILABLE
  Register ImageSet::appendInfo(ImageInfoKey key, Context *ctx)
  {
    auto it = infoRegMap.find(key.data);
    if (it != infoRegMap.end())
      return it->second;
    Register reg = ctx->reg(FAMILY_DWORD, false, GBE_CURBE_IMAGE_INFO, key.data);
    infoRegMap.insert(std::make_pair(key.data, reg));
    return reg;
  }

  void ImageSet::append(Register imageReg, Context *ctx, uint8_t bti)
  {
    ir::FunctionArgument *arg =  ctx->getFunction().getArg(imageReg);
    GBE_ASSERTM(arg && arg->type == ir::FunctionArgument::IMAGE, "Append an invalid reg to image set.");
    GBE_ASSERTM(regMap.find(imageReg) == regMap.end(), "Append the same image reg twice.");

    int32_t id = ctx->getFunction().getArgID(arg);
    struct ImageInfo *imageInfo = GBE_NEW(struct ImageInfo);
    imageInfo->arg_idx = id;
    imageInfo->idx = bti;
    imageInfo->wSlot = -1;
    imageInfo->hSlot = -1;
    imageInfo->depthSlot = -1;
    imageInfo->dataTypeSlot = -1;
    imageInfo->channelOrderSlot = -1;
    imageInfo->dimOrderSlot = -1;
    regMap.insert(std::make_pair(imageReg, imageInfo));
    indexMap.insert(std::make_pair(imageInfo->idx, imageInfo));
  }
#endif

} /* namespace ir */
} /* namespace gbe */
