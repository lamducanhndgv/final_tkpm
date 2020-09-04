let registerButton = document.getElementById('register-btn');

registerButton.addEventListener('click', (e) => {
    let username = document.getElementById('register-username').value;
    let password = document.getElementById('register-password').value;
    let confirm = document.getElementById('register-confirm').value;

    if(username==''||password==''||confirm==''){
        alert('All field must be filled!')
    }
    else if(password!==confirm) {
        alert('Confirm password does not match!')
    }
    else {
        registerForm(username, password)
    }
})

let registerForm = (username, password) => {
    let data = JSON.stringify({
        username: username,
        password: password
    })

    var xhttp = new XMLHttpRequest();
    xhttp.responseType = 'json';
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
           let res = xhttp.response// Typical action to be performed when the document is ready:
           alert(res.message)
           window.location.replace(logURL)
        }
        else if (this.readyState == 4 && this.status == 400) {
            let res = xhttp.response// Typical action to be performed when the document is ready:
            alert(res.message)
         }
    };
    xhttp.open("POST", regURL, true);
    xhttp.send(data);
}