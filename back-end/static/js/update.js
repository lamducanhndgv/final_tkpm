let modelSelector = document.getElementById('model-selection');
let chooseBtn = document.getElementById('choose-model-btn');
let form = document.getElementById('update-form')

let updateItemsList = []

chooseBtn.addEventListener('click', (e) => {
    let choosenModel = modelSelector.value;
    if(choosenModel==='') {
        alert('Bạn phải chọn model')
        return;
    }

    choose(choosenModel)
})

let choose = (choosenModel) => {
    let username = getCookie('username');
    let data = JSON.stringify({
        username: username,
        model: choosenModel
    })

    var xhttp = new XMLHttpRequest();
    xhttp.responseType = 'json';
    xhttp.onreadystatechange = function() {
        let resdata = xhttp.response.data
        form.style.visibility = 'visible';
        form.innerHTML = getTemplate(resdata)

        let paramTable = form.querySelector('#update-param-table');
        let addBtn = form.querySelector('#add-updateparam-btn');
        let updateBtn = form.querySelector('#update-btn')

        addBtn.addEventListener('click', (e) => {
            let cls = ["param-row", "d-flex", "justify-content-between", "pt-3"];
            let div = document.createElement('div');
            div.classList.add(...cls); 

            div.innerHTML = `
                <button onclick="removeUpdateInput(this)" class="remove-item-btn">&times;</button>
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
            updateItemsList.push(div)
        })

        updateBtn.addEventListener('click', (e) => {
            updateModel(form);
        })
    };
    xhttp.open("POST", updateURL, true);
    xhttp.send(data);
}

let getTemplate = (data) => {
    let model = _.find(data, (item) => !_.isEmpty(item.modelname));
    let framework = _.find(data, (item) => item.type==="framework");
    let command = _.find(data, (item) => item.type==="command");
    let inputs = _.filter(data, (item) => item.parameter !== undefined);

    let html = `
    <div class="d-flex flex-columns justify-content-between mb-4">
        <label for="model-name">Model's name</label>
        <input id="model-name" type="text" name="model-name" value="${model.modelname}" disabled/>
    </div>

    <div id="cmd-form" class="mb-3">
        <div class="main d-flex justify-content-between">
            <span>Framework</span>
            <select id="framework" class="custom-select mb-4" style="width: 250px;">
                ${getFrameworkInput(framework.value)}
            </select>
        </div>
        <div class="main d-flex justify-content-between">
            <span>Command</span>
            <select id="command" class="custom-select mb-4" style="width: 250px;">
                ${getCommandInput(command.value)}
            </select>
        </div>  
        <div class="main d-flex justify-content-between">
            <span>Params</span>
            <button id="add-updateparam-btn">
                +
            </button>
        </div>    
        <div id="update-param-table" class="ml-3 ">
            ${getParamTable(inputs)}
        </div>
    </div>

    <button id="update-btn">Update</button>
    <button class="btn btn-warning d-none" type="button" id="cancel-btn">Cancel update</button>

    <div id="progress_wrapper" class="d-none">
        <label id="progress_status"></label>
        <div class="progress mb-3">
            <div id="progress" class="progress-bar" role="progressbar" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100"></div>
        </div>
    </div>

    <div id="alert_wrapper"></div>`

    return html;
}

let getFrameworkInput = (framework) => {
    switch (framework) {
        case "tensorflow":
            return `<option value="tensorflow" selected>Tensorflow</option>
                    <option value="pytorch">Pytorch</option>
                    <option value="darknet">Darknet</option>
                    `
        case "pytorch":
            return `<option value="tensorflow">Tensorflow</option>
                    <option value="pytorch" selected>Pytorch</option>
                    <option value="darknet">Darknet</option>
                    `
        case "pytorch":
            return `<option value="tensorflow">Tensorflow</option>
                    <option value="pytorch">Pytorch</option>
                    <option value="darknet" selected>Darknet</option>
                    `
        default:
            return `<option value="" selected>Choose the framework</option>
                    <option value="tensorflow">Tensorflow</option>
                    <option value="pytorch">Pytorch</option>
                    <option value="darknet">Darknet</option>
                    `
    }
}

let getCommandInput = (command) => {
    switch (command) {
        case "python":
            return `<option value="python" selected>Python</option>
                    <option value="darknet">Darknet</option>
                    `
        case "darknet":
            return `<option value="python">Python</option>
                    <option value="darknet" selected>Darknet</option>
                    `
        default:
            return `<option value="" selected>Choose the command</option>
                    <option value="python">Python</option>
                    <option value="darknet">Darknet</option>
                    `
    }
}

let getInputHTML = (type) => {
    switch (type) {
        case "param":
            return `<option value="param" selected>Param</option>
                    <option value="input">Input</option>
                    <option value="output">Output</option>
                    `
        case "input":
            return `<option value="param">Param</option>
                    <option value="input" selected>Input</option>
                    <option value="output">Output</option>
                    `
        case "output":
            return `<option value="param">Param</option>
                    <option value="input">Input</option>
                    <option value="output" selected>Output</option>
                    `
        default:
            return `<option value="" selected>Choose</option>
                    <option value="param">Param</option>
                    <option value="input">Input</option>
                    <option value="output">Output</option>
                    `
    }
}

let getParamTable = (inputs) => {
    let parentDiv = document.createElement('div');

    for(let i=0; i<inputs.length; i++) {
        let input = inputs[i];

        let cls = ["param-row", "d-flex", "justify-content-between", "pt-3"];
        let div = document.createElement('div');
        div.classList.add(...cls); 

        div.innerHTML = `
            <button onclick="removeUpdateInput(this)" class="remove-item-btn">&times;</button>
            <div class="d-flex flex-column align-item-start">
                <span style="font-size: 17px;">Type</span>
                <select class="custom-select mb-4" style="height: 30px; width: 100px;font-size: 15px; font-size: 13px;">
                    ${getInputHTML(input.type)}
                </select>
            </div>
            <div class="d-flex flex-column align-item-start">
                <span style="font-size: 17px;">Parameter</span>
                <input type="text" value="${input.parameter}" style="width: 150px;font-size: 15px;">
            </div>
            <div class="d-flex flex-column align-item-start">
                <span style="font-size: 17px;">Value</span>
                <input type="text" value="${input.value}" style="width: 100px;font-size: 15px;">
            </div>
        `;

        parentDiv.appendChild(div);
        updateItemsList.push(div)
    }

    return parentDiv.innerHTML;
}

let removeUpdateInput = (elem) => {
    let div = elem.parentNode;
    var index = updateItemsList.indexOf(div);
    updateItemsList.splice(index, 1);
    div.remove();
}

let updateModel = (form) => {
    let data = new FormData();
    let request = new XMLHttpRequest();
    let alert_wrapper = form.querySelector('#alert_wrapper')
    let updateBtn = form.querySelector('#update-btn')
    let progress_wrapper = form.querySelector('#progress_wrapper')
    let model_name = form.querySelector('#model-name')

    request.responseType = 'json';
    alert_wrapper.innerHTML = "";

    updateBtn.classList.add("d-none");
    progress_wrapper.classList.remove("d-none");

    let modelname = model_name.value;

    data.append('modelname', modelname)
    data.append('config', getUpdateParamAsJson())

    request.addEventListener("load", function(e) {
        if(request.status == 200) {
            update_show_alert(alert_wrapper, `${request.response.message}`, "success");
        }
        else if (request.status == 500){
            update_show_alert(alert_wrapper, `${request.response.message}`, "warning")
        }
        else if (request.status == 401){
            update_show_alert(alert_wrapper, `${request.response.message}`, "danger")
        }
        else {
            update_show_alert(alert_wrapper, "Error uploading file", "danger");
        }

        updateReset(form);
    })


    request.open('POST', updatemodelURL)
    request.setRequestHeader('Authorization', getCookie('token'));  
    request.send(data)
}

let getUpdateParamAsJson = () => {
    var jsonArray = [];

    jsonArray.push({
        type: "framework",
        value: $( "#framework option:selected" ).val()
    })

    jsonArray.push({
        type: "command",
        value: $( "#command option:selected" ).val()
    })

    for(var i=0; i<updateItemsList.length; i++) {
        let div = updateItemsList[i];

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

function updateReset(form) {
    let updateBtn = form.querySelector('#update-btn')
    let progress_wrapper = form.querySelector('#progress_wrapper')
    let progress = form.querySelector('#progress')


    progress_wrapper.classList.add("d-none")
    updateBtn.classList.remove("d-none")
    progress.setAttribute("style", "width: 0%;");
}

function update_show_alert(alert_wrapper, message, alert) {
    alert_wrapper.innerHTML = `
        <div class="alert alert-${alert} alert-dismissible fade show" role="alert">
            <span>${message}</span>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    `;
}