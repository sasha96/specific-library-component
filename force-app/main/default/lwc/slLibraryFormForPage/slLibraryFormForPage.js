import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLibraryItemsByName from "@salesforce/apex/SL_ctrl_LibraryFormHandler.getLibraryItemsByName";
import saveFile from "@salesforce/apex/SL_ctrl_LibraryFormHandler.saveFile";
import createRemoveLinks from "@salesforce/apex/SL_ctrl_LibraryFormHandler.createRemoveLinks";
import getLibraryName from "@salesforce/apex/SL_ctrl_LibraryFormHandler.getLibraryName";
import getFilesFromFolder from "@salesforce/apex/SL_ctrl_LibraryFormHandler.getFilesFromFolder";
import saveFileInFolder from "@salesforce/apex/SL_ctrl_LibraryFormHandler.saveFileInFolder";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SlLibraryFormForPage extends NavigationMixin(LightningElement) {

    @api libraryName;
    @api isShowUploadButton;
    @api isAbleToDelete;
    @api isMultiSelect;
    @api fileCount = 0;
    @api showSpinner = false;
    @api disableAddButton = false;
    @api recordId;
    @api folderName;
    @api lstCreatedLinks;
    @track libraryRecord = "";
    @track initialListOfFiles = "";
    @track listOfFiles = "";
    @track searchValue = "";
    @track searchKey = "";
    @track fileName = "";
    @track selectedFileCount = 0;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;

    /* method calls automatically after initialization */
    connectedCallback() {

        this.showSpinner = true;
        this.disableAddButton = true;

        if (this.folderName) {
            this.finElementFromFolder();
        } else {
            this.findLibraryName();
        }
    }

    finElementFromFolder() {

        getFilesFromFolder({
            folderName: this.folderName,
            recordId: this.recordId
        })
            .then(result => {
                this.prepareAllDate(result);

            })
            .catch(error => {
                const toastEvnt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error happend when you tried to retrieve files from folder. ' + error.body.message,
                    variant: 'error',
                    duration: 5000
                });
                this.dispatchEvent(toastEvnt);
                this.closeWindow();
            })
    }

    /*find library name */
    findLibraryName() {

        getLibraryName()
            .then(result => {
                this.libraryName = JSON.parse(result).Library_Name__c;
                this.initialize();
            })
            .catch(error => {

                const toastEvnt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error happend when you tried to retrieve name of library. ' + error.body.message,
                    variant: 'error',
                    duration: 5000
                });
                this.dispatchEvent(toastEvnt);
                this.closeWindow();
            })
    }

    /* initialize method */
    initialize() {

        getLibraryItemsByName({
            libraryName: this.libraryName,
            recordId: this.recordId
        })
            .then(result => {

                this.prepareAllDate(result);
            })
            .catch(error => {
                const toastEvnt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error happend when you tried to retrieve files from library',
                    variant: 'error',
                    duration: 5000
                });
                this.dispatchEvent(toastEvnt);
            });

    }

    /* calls for formating datetime */
    formatDatehelper(date) {

        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12;
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;

    }

    /* calls for formating size */
    formatSizeHelper(size) {

        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (size == 0) return '0 Byte';
        var i = parseInt(Math.floor(Math.log(size) / Math.log(1024)));
        return Math.round(size / Math.pow(1024, i), 2) + ' ' + sizes[i];
    }

    /* checkbox handler method */
    handleCheckboxChange(event) {

        var listOfFiles = this.listOfFiles;
        this.listOfFiles = [];
        var checked = false;
        var selectedFileCount = 0;

        for (var elem in listOfFiles) {
            if (listOfFiles[elem].Id === event.target.dataset.id) {
                listOfFiles[elem].isChecked = !listOfFiles[elem].isChecked;
                checked = listOfFiles[elem].isChecked;
            }

            if (listOfFiles[elem].isChecked) {
                selectedFileCount++;
            }
        }
        var isCheched = false;
        listOfFiles.forEach(item => {
            if (!isCheched) {
                if (item.isChecked && !item.hasBeenCreated) {
                    isCheched = true;
                }
                if (!item.isChecked && item.hasBeenCreated) {
                    isCheched = true;
                }
            }
        })
        this.disableAddButton = isCheched > 0 ? false : true;

        this.selectedFileCount = selectedFileCount;

        if (!this.isMultiSelect) {
            if (checked) {
                listOfFiles.forEach(element => {
                    if (element.isChecked) {
                        element.isDisable = false;
                    } else {
                        element.isDisable = true;
                    }
                });
            } else {
                listOfFiles.forEach(element => {
                    element.isDisable = false;
                });
            }
        }

        this.listOfFiles = listOfFiles;

    }

    /* prepare all data before showing */
    prepareAllDate(result) {
        var returnedData = JSON.parse(result);
        var lstCreatedLinks = returnedData.lstCreatedLinks;
        this.lstCreatedLinks = returnedData.lstCreatedLinks;;
        this.libraryRecord = returnedData.libraryRecord;

        var listOfFiles = [];
        for (var i in returnedData.lstFolderItems) {
            var fileExt = returnedData.lstFolderItems[i].FileExtension.toLowerCase();
            if (fileExt === 'jpeg' || fileExt === 'png' || fileExt === 'jpg' || fileExt === 'gif' || fileExt === 'tiff') {
                fileExt = 'image';
            }

            listOfFiles.push({
                Id: returnedData.lstFolderItems[i].Id,
                Title: returnedData.lstFolderItems[i].Title,
                LastModifiedDate: this.formatDatehelper(new Date(returnedData.lstFolderItems[i].LastModifiedDate)),
                ContentSize: this.formatSizeHelper(returnedData.lstFolderItems[i].ContentSize),
                FileExtension: fileExt,
                iconName: 'doctype:' + fileExt,
                isChecked: false,
                isDisable: false,
                hasBeenCreated: false,
                showMessage: false,
                disableDeleteCreatedFiles: false
            });
        }

        var selectedFileCount = 0;
        listOfFiles.forEach(file => {
            lstCreatedLinks.forEach(createdFile => {
                if (createdFile.ContentDocumentId === file.Id) {
                    file.isChecked = true;
                    file.hasBeenCreated = true;
                    selectedFileCount++;
                }
                if (file.hasBeenCreated && !this.isAbleToDelete) {
                    file.disableDeleteCreatedFiles = true;
                }
            })
        });

        this.selectedFileCount = selectedFileCount;
        this.listOfFiles = listOfFiles;
        this.initialListOfFiles = listOfFiles;
        this.fileCount = listOfFiles.length;
        this.showSpinner = false;
    }

    /* handler search method */
    changeSearchElement(event) {

        if (this.searchKey !== event.target.value) {
            this.searchKey = event.target.value;
            this.updateListDueToSerch(event);
        }
    }

    /* handler search method */
    updateListDueToSerch(event) {

        var searchedString = this.searchKey;
        var newListOfFiles = this.initialListOfFiles.filter(file => file.Title.indexOf(searchedString) > -1);
        this.listOfFiles = newListOfFiles;
    }

    /* handler upload new files method */
    uploadFileHandler(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;

            this.uploadHelper();
        }

    }

    /* handler upload new files method */
    uploadHelper() {
        this.showSpinner = true;
        this.file = this.filesUploaded[0];
        var fileNames = [];
        for (var i = 0; i < this.filesUploaded.length; i++) {
            fileNames.push(this.filesUploaded[i].name);
        }

        this.fileReader = new FileReader();

        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);

            if (this.folderName) {
                saveFileInFolder({
                    strFileNames: fileNames,
                    base64Data: encodeURIComponent(this.fileContents),
                    idOfLibrary: this.libraryRecord.Id,
                    folderName: this.folderName
                })
                    .then(result => {
                        this.finElementFromFolder();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success!!',
                                message: fileNames + ' - Uploaded Successfully!!!',
                                variant: 'success',
                            }),
                        );
                        this.showSpinner = false;

                    })
                    .catch(error => {
                        const toastEvnt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Error happend when you tried to uploadHelper files.' + error.body.message,
                            variant: 'error',
                            duration: 5000
                        });
                        this.dispatchEvent(toastEvnt);
                        this.showSpinner = false;
                    });
            } else {
                saveFile({
                    strFileNames: fileNames,
                    base64Data: encodeURIComponent(this.fileContents),
                    idOfLibrary: this.libraryRecord.Id
                })
                    .then(result => {
                        this.initialize();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success!!',
                                message: fileNames + ' - Uploaded Successfully!!!',
                                variant: 'success',
                            }),
                        );
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        const toastEvnt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Error happend when you tried to uploadHelper files',
                            variant: 'error',
                            duration: 5000
                        });
                        this.dispatchEvent(toastEvnt);
                        this.showSpinner = false;
                    });
            }
        });


        this.fileReader.readAsDataURL(this.file);
    }

    /* method close modal window*/
    closeWindow(event) {
        this.dispatchEvent(new CustomEvent('closeWindow', {}));
    }

    /* method creates new file links and remove unchecked*/
    addFilesHandler(event) {


        this.showSpinner = true;

        var initialListOfFiles = this.initialListOfFiles;
        var lstIdsToCreate = [];
        var listOfFielsToRemove = [];

        for (var item in initialListOfFiles) {

            if (initialListOfFiles[item].isChecked && !initialListOfFiles[item].hasBeenCreated) {
                lstIdsToCreate.push(initialListOfFiles[item].Id)
            }
            if (!initialListOfFiles[item].isChecked && initialListOfFiles[item].hasBeenCreated) {
                listOfFielsToRemove.push(initialListOfFiles[item].Id)
            }
        }

        createRemoveLinks({
            listOfFielsToInsert: lstIdsToCreate,
            listOfFielsToRemove: listOfFielsToRemove,
            recordId: this.recordId
        })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Uploaded successfully create ' + lstIdsToCreate.length +
                            ' and remove ' + listOfFielsToRemove.length + ' files links',
                        variant: 'success',
                    }),
                );

                this.showSpinner = false;

                this.dispatchEvent(new CustomEvent('closeWindow', {
                    detail: { reloadPage: true },
                }));

            })
            .catch(error => {
                const toastEvnt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error happend when you tried to create new link on files',
                    variant: 'error',
                    duration: 5000
                });
                this.dispatchEvent(toastEvnt);
                this.showSpinner = false;
            });

    }

    /* calls whenever hover on under tooltip  icon*/
    display(event) {

        var selectedId = event.target.dataset.id;

        var listOfFiles = this.listOfFiles;
        for (var item in listOfFiles) {
            if (listOfFiles[item].Id === selectedId) {
                listOfFiles[item].showMessage = true;
            }
        }

        this.listOfFiles = listOfFiles;

    }

    /* calls whenever hover out under tooltip  icon*/
    displayOut(event) {

        var listOfFiles = this.listOfFiles;
        for (var item in listOfFiles) {
            listOfFiles[item].showMessage = false;
        }
        this.listOfFiles = listOfFiles;
    }

    /*open file in new tab */
    openFileInNewTab(event) {

        var selectedId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedId,
                actionName: 'view'
            }
        });

    }
}