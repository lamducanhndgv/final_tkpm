let logoutURL = 'http://localhost:8888/logout'
let logoutButton = document.getElementById('logout-btn')

logoutButton.addEventListener('click', (e)=> {
    let xhttp = new XMLHttpRequest();
    xhttp.responseType = 'json';
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            window.location.replace('http://localhost:8888/')
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
    upload('http://localhost:8888/')
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