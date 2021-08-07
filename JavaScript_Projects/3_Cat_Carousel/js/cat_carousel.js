const cats=[
    {
        id:1,
        name:"Bruce",
        job:"Boss cat",
        info:"Favourite food: ham",
        img:"./images/bruce.jpg"
    },
    {
        id:2,
        name:"Chopper",
        job:"Cuddly cat",
        info:"Favourite food: chicken",
        img:"./images/chopper.jpg"
     },
     {
        id:3,
        name:"Luna",
        job:"Guard cat",
        info:"Favourite food: biscuits",
        img:"./images/luna.jpg"
     },
     {
        id:4,
        name:"Vesta",
        job:"Purring cat",
        info:"Favourite food: wet pouch",
        img:"./images/vesta.jpg"
     }
]
// my code
catId=1

next=document.querySelector(".next-btn");
next.addEventListener("click",function(){
   if(catId==cats.length){catId=1}else{catId++};
   updateCat()
})
prev=document.querySelector(".prev-btn");
prev.addEventListener("click",function(){
   if(catId==1){catId=cats.length}else{catId--};
   updateCat()
})
random=document.querySelector(".random-btn");
random.addEventListener("click",function(){
    catNext=catId
    while(catNext==catId){
        catNext=Math.floor(Math.random()*cats.length)+1;
    }
    catId=catNext;
    updateCat();
})

function updateCat(){
    document.getElementById("cat").innerText=cats[catId-1].name;
    document.getElementById("job").innerText=cats[catId-1].job;
    document.getElementById("info").innerText=cats[catId-1].info;
    document.getElementById("person-img").src=cats[catId-1].img;
}



