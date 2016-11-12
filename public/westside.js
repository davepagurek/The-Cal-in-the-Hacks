function showSection(id) {
  Array.prototype.forEach.call(
    document.querySelectorAll("section"),
    function(element) {
      if (element.id == id) {
        element.classList.remove("hidden");
      } else {
        element.classList.add("hidden");
      }
    }
  );
}

function showLoader() {
  showSection("loader");
}

function loadSeeds() {
  showLoader();
  axios.get('/sample_words').then(function(response) {
    console.log(response);
    // clear seeds
    var seeds = document.querySelector('#seeds');
    while (seeds.firstChild) {
      seeds.removeChild(seeds.firstChild);
    }

    response.data.words.forEach(function(seed) {
      seedBtn = document.createElement("button");
      seedBtn.textContent = seed;
      seedBtn.addEventListener("click", function() {
        generate(seed);
      });
      seeds.appendChild(seedBtn);
    });

    showSection('intro');
  });
}

function generate(seed) {
  alert("Not implemented yet :)");
}

loadSeeds();
