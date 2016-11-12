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
    // clear seeds
    var seeds = document.querySelector('#seeds');
    while (seeds.firstChild) {
      seeds.removeChild(seeds.firstChild);
    }

    // append new seeds
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
  showLoader();
  axios.post('/generate', {seed: seed}).then(function(response) {
    // clear verses
    var verses = document.querySelector('#verses');
    while (verses.firstChild) {
      verses.removeChild(verses.firstChild);
    }

    response.data.lines.forEach(function(line) {
      var lineDiv = document.createElement("div");
      lineDiv.textContent = line;
      verses.appendChild(lineDiv);
    });

    showSection("rap");
  });
}

document.querySelector("#more").addEventListener("click", loadSeeds);
document.querySelector("#another").addEventListener("click", loadSeeds);
loadSeeds();