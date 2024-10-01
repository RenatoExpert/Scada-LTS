// RelatoryView.js
class RelatoryView {
    downloadXlsx() {
        console.log("xlsx");
    }

    checkRelatoryThenSave(data, filename, type) {
        if (this.generated_relatory) {
            this.saveFile(data, filename, type);
        } else {
            throw new Error("No relatory generated to be saved!");
        }
    }

    saveFile(data, filename, type) {
        let file = new Blob([data], { type });
        let anchor = document.createElement("a");
        let url = URL.createObjectURL(file);
        anchor.href = url;
        anchor.download = filename;
        document.body.appendChild(anchor);
        anchor.click();
        document.body.removeChild(anchor);
        window.URL.revokeObjectURL(url);
    }
}

export default RelatoryView;
