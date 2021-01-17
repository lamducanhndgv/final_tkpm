let userSelector = document.getElementById('user-selection');
let subscribeBtn = document.getElementById('subscribe-btn');

subscribeBtn.addEventListener('click', (e) => {
    let subscribe_user = userSelector.value;
    if(subscribe_user==='') {
        alert('Bạn phải chọn người đăng kí')
        return;
    }

    subscribe(subscribe_user)
})

let subscribe = (subscribe_user) => {
    let username = getCookie('username');
    let data = JSON.stringify({
        current_user: username,
        subscribe_user: subscribe_user
    })

    var xhttp = new XMLHttpRequest();
    xhttp.responseType = 'json';
    xhttp.onreadystatechange = function() {
        let res = xhttp.response
        alert(res.message)
    };
    xhttp.open("POST", subscribeURL, true);
    xhttp.send(data);
}