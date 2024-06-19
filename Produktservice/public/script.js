window.onload = () => {
    showPizza();
};

function showPizza() {
    const container = document.getElementById("allPizza");
    container.textContent = "";

    fetch("/pizza")
        .then((res) => res.json())
        .then((body) => {
            console.log(body);
            if (!body) return;

            Object.keys(body).forEach((pizza) => {
                const spreis = body[pizza].S;
                const mpreis = body[pizza].M;
                const lpreis = body[pizza].L;

                const newDiv = document.createElement("div");
                newDiv.classList.add("pizza-container")
                const name = document.createElement("span");
                name.className = "bold"
                name.innerHTML = pizza;
                const s = document.createElement("span");
                if (spreis) s.innerHTML = "S: " + spreis;
                const m = document.createElement("span");
                if (mpreis) m.innerHTML = "M: " + mpreis;
                const l = document.createElement("span");
                if (lpreis) l.innerHTML = "L: " + lpreis;

                newDiv.append(name, s, m, l);
                container.append(newDiv);
            });
        });
}

function onSubmit(form, e) {
    e.preventDefault();
    document.getElementById("hinweis").style = "display: none;";
    document.getElementById("error").style = "display: none;";

    const data = {
        Name: form.name.value,
        S: form.spreis.value,
        M: form.mpreis.value,
        L: form.lpreis.value,
    };

    fetch("/create_produkt", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
    }).then((res) => {
        if (res.ok) {
            document.getElementById("hinweis").style = "display: inherit;";
            showPizza();
        } else {
            document.getElementById("error").style = "display: inherit;";
        }
    });

    return false;
}