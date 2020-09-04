let loginButton = document.getElementById('login-btn');

loginButton.addEventListener('click', (e) => {
    let username = document.getElementById('login-username').value;
    let password = document.getElementById('login-password').value;

    loginForm(username, password)
})

let loginForm = (username, password) => {
    let data = JSON.stringify({
        username: username,
        password: password
    })

    var xhttp = new XMLHttpRequest();
    xhttp.responseType = 'json';
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            let res = xhttp.response// Typical action to be performed when the document is ready:
            setCookie('token',res.token,2);
            window.location.replace(hostURL)
        }
        else if (this.readyState == 4 && this.status == 401) {
            let res = xhttp.response// Typical action to be performed when the document is ready:
            alert(res.message)
         }
    };
    xhttp.open("POST", logURL, true);
    xhttp.send(data);
}