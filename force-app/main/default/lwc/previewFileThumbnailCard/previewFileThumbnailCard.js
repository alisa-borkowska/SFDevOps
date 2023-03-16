import { LightningElement, api, wire } from "lwc";
import updateDisplayUrl from "@salesforce/apex/FileController.updateDisplayUrl";

export default class PreviewFileThumbnailCard extends LightningElement {
  @api file;
  @api recordId;
  @api thumbnail;

  get iconName() {
    if (this.file.Extension) {
        if (!['jpg'].some(v => v == this.file.Extension)) {
            throw MediaError("Specified file format does not match allowed formats. Please choose file in jpg format.")
        }
    }
    return "doctype:image";
  }

  filePreview() {
    console.log("###Click");
    const showPreview = this.template.querySelector("c-preview-file-modal");
    showPreview.show();
  }

  @wire (updateDisplayUrl, { recordId: recordId, imageUrl: "$thumbnail" })
  handleChange(success) {
    console.log("dziala")
    if (success)
      this.dispatchEvent(new CustomEvent('change', {thumbnail: this.thumbnail}))
  }

  setAsDefault() {
    this.dispatchEvent(new CustomEvent('change', {detail: this.thumbnail}))
  }

  deleteItem() {
    this.dispatchEvent(new CustomEvent('delete', {detail: this.file.Id}))

  }


}


