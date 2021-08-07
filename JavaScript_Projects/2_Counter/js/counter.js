counter = document.getElementById("counter")
decrease = document.getElementById("decrease");
decrease.addEventListener("click", function(){
    counter.innerText=counter.innerText-1
})

reset = document.getElementById("reset")
reset.addEventListener("click", function(){
    counter.innerText=0
})

increase = document.getElementById("increase")
increase.addEventListener("click", function(){
    counter.innerText=parseInt(counter.innerText)+1
})
// Teacher code below
let count = 0;
const value = document.querySelector("#value");
const btns = document.querySelectorAll(".btn");

btns.forEach(function(btn){
    btn.addEventListener("click", function(e){
        const styles = e.currentTarget.classList;
        if(styles.contains("decrease")){
            count--;
        }else if(styles.contains("reset")){
            count = 0
        }else if(styles.contains("increase")){
            count++
        }
        if(count<0){
            value.style.color = "red";
        }else if(count==0){
            value.style.color = "black";
        }else{
            value.style.color = "green";
        }
        value.textContent = count;
    })
})