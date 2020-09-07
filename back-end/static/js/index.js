let logoutButton = document.getElementById('logout-btn')

logoutButton.addEventListener('click', (e)=> {
    let xhttp = new XMLHttpRequest();
    xhttp.responseType = 'json';
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            window.location.replace(hostURL)
        }
    };
    xhttp.open('POST', logoutURL, true);
    xhttp.send();
})


// uploading file
let uploadBtn = document.getElementById('upload-btn')
let cancelBtn = document.getElementById('cancel-btn')
let inputName = document.getElementById('model-name')
let inputFile = document.getElementById('file-container')

uploadBtn.addEventListener('click', (e)=> {
    upload(hostURL)
})


// progressbar
let progress = document.getElementById('progress')
let progress_wrapper = document.getElementById('progress_wrapper')
let progress_status = document.getElementById('progress_status')
let alert_wrapper = document.getElementById('alert_wrapper')

function show_alert(message, alert) {
    alert_wrapper.innerHTML = `
        <div class="alert alert-${alert} alert-dismissible fade show" role="alert">
            <span>${message}</span>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    `;
}

function upload(url) {
    if(!inputFile.value) {
        show_alert('No file selected!', "danger");
        return;
    }

    if(!inputName.value) {
        show_alert('Model must have name!', "danger");
        return;
    }

    let data = new FormData();
    let request = new XMLHttpRequest();

    request.responseType = 'json';
    alert_wrapper.innerHTML = "";
    inputFile.disabled = true;

    uploadBtn.classList.add("d-none");
    progress_wrapper.classList.remove("d-none");
    cancelBtn.classList.remove("d-none")

    let file = inputFile.files[0]
    let modelname = inputName.value;

    data.append('file', file);
    data.append('modelname', modelname)
    data.append('config', getParamAsJson())
    
    request.upload.addEventListener("progress", function(e){
        let loaded = e.loaded;
        let total = e.total;

        let percentage_complete = (loaded/total)*100;
        progress.setAttribute("style", `width: ${Math.floor(percentage_complete)}%`);
        progress_status.innerText = `Status: ${Math.floor(percentage_complete)}% uploaded`;
    })

    request.addEventListener("load", function(e) {
        if(request.status == 200) {
            show_alert(`${request.response.message}`, "success");
        }
        else if (request.status == 500){
            show_alert(`${request.response.message}`, "warning")
        }
        else if (request.status == 401){
            show_alert(`${request.response.message}`, "danger")
        }
        else {
            show_alert("Error uploading file", "danger");
        }

        reset();
    })

    request.addEventListener("error", function(e) {
        reset();
        show_alert("Error uploading file", "danger");
    })


    request.open('POST', url)
    request.setRequestHeader('Authorization', getCookie('token'));
    // request.setRequestHeader('token', getCookie('token'));
    request.send(data)

    cancelBtn.addEventListener('click', function(e) {
        request.abort();
        reset();
    })
}

function reset() {
    inputFile.value = null;
    inputFile.disabled = false;
    progress_wrapper.classList.add("d-none")
    uploadBtn.classList.remove("d-none")
    cancelBtn.classList.add("d-none")
    progress.setAttribute("style", "width: 0%;");
}

// add params
let addParamBtn = document.getElementById("add-param-btn")
let paramTable = document.getElementById("param-table")
let itemList = []

addParamBtn.addEventListener('click', (e)=> {
    let cls = ["param-row", "d-flex", "justify-content-between", "pt-3"];
    let div = document.createElement('div');
    div.classList.add(...cls); 

    div.innerHTML = `
        <button onclick="remove(this)" class="remove-item-btn">&times;</button>
        <div class="d-flex flex-column align-item-start">
            <span style="font-size: 17px;">Type</span>
            <select class="custom-select mb-4" style="height: 30px; width: 100px;font-size: 15px; font-size: 13px;">
                <option value="" selected>Choose</option>
                <option value="param">Param</option>
                <option value="input">Input</option>
                <option value="output">Output</option>
            </select>
        </div>
        <div class="d-flex flex-column align-item-start">
            <span style="font-size: 17px;">Parameter</span>
            <input type="text" style="width: 150px;font-size: 15px;">
        </div>
        <div class="d-flex flex-column align-item-start">
            <span style="font-size: 17px;">Value</span>
            <input type="text" style="width: 100px;font-size: 15px;">
        </div>
    `;


    paramTable.appendChild(div);
    itemList.push(div)
})

function remove(elem) {
    let div = elem.parentNode;
    var index = itemList.indexOf(div);
    itemList.splice(index, 1);
    div.remove();
}

function getParamAsJson() {
    var jsonArray = [];

    jsonArray.push({
        type: "framework",
        value: $( "#framework option:selected" ).val()
    })

    jsonArray.push({
        type: "command",
        value: $( "#command option:selected" ).val()
    })

    for(var i=0; i<itemList.length; i++) {
        let div = itemList[i];

        let Type = div.getElementsByTagName("select")[0];
        let Parameter = div.getElementsByTagName("input")[0];
        let Value = div.getElementsByTagName("input")[1];

        let type = Type.options[Type.selectedIndex].value;
        let parameter = Parameter.value;
        let value = Value.value;

        jsonArray.push({
            type: type,
            parameter: parameter,
            value: value
        })
    }

    return JSON.stringify(jsonArray)
}