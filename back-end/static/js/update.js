let modelSelector = document.getElementById('model-selection');
let chooseBtn = document.getElementById('choose-model-btn');
let form = document.getElementById('update-form')

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
            <button id="add-param-btn">
                +
            </button>
        </div>    
        <div id="param-table" class="ml-3 ">
            ${getParamTable(inputs)}
        </div>
    </div>

    <button id="upload-btn">Upload</button>
    <button class="btn btn-warning d-none" type="button" id="cancel-btn">Cancel upload</button>

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

let updateItemsList = []

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
            <button onclick="remove(this)" class="remove-item-btn">&times;</button>
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

function removeUpdateInput(elem) {
    let div = elem.parentNode;
    var index = itemList.indexOf(div);
    updateItemsList.splice(index, 1);
    div.remove();
}