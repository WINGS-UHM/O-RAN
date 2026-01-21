<h1 align="center">O-RAN/AI-RAN Testbed</h1>
<h3 align="center">This Project Display the On-site Open-RAN/AI-RAN Testbed Architecture @ UHM</h3>

---

![last commit](https://img.shields.io/github/last-commit/WINGS-UHM/O-RAN?cacheSeconds=60)
![stars](https://img.shields.io/github/stars/WINGS-UHM/O-RAN?style=social&cacheSeconds=60)
![license](https://img.shields.io/github/license/WINGS-UHM/O-RAN?cacheSeconds=60)


✍️✍️ **Authors** ✍️✍️ [No ranking]
- Xiaochan Xue (Assistant Professor at UH Manoa) <br>
- Saurabh Parkar (Ph.D. Student at UH Manoa) <br>
- Thomas Yang (Master Student at UH Manoa) <br>
- Aris Carlos (Master Student at UH Manoa) <br>
- Ethan Morrell (Master Student at UH Manoa)

<h2 align="center">👇👇 Get Started 👇👇</h2>

<a id="server-specification"></a>
<details>
  <summary><strong>Server Specification</strong></summary>

- **CPU**     : AMD Ryzen 9  
- **GPU**     : NVIDIA RTX 5070 Ti  
- **Memory**  : 64GB  
- **Storage** : 2TB SSD  

</details>

<a id="rf-devices"></a>
<details>
  <summary><strong>RF Devices</strong></summary>

- **SDRs**    : X410 (1), X310 (1), N210 (Multiple), clock (1)  
- **iPass**  
- **Antennas** : Horn antenna, omni, directional, RIS  

</details>


<a id="o-ran-stack"></a>
<details>
  <summary><strong>O-RAN Stack</strong></summary>

1. [Near RT-RIC (i-release)](https://github.com/srsran/oran-sc-ric)
2. [Near RT-RIC (j-release)](https://lf-o-ran-sc.atlassian.net/wiki/spaces/IAT/pages/14516684/Near-RT+RIC+J+Release)
   - Also refer [[Demo](https://zoom.us/rec/play/-crjV6kqiOjdG7zpMyQpj-1xcGV9L08r87hlVSmGhbcaK7KPUGkpkXCHnqdxEe0qzYbt2lKfJT2wX6cP.VjV0IXRtRO90Q7bY?canPlayFromShare=true&from=share_recording_detail&continueMode=true&componentName=rec-play&originRequestUrl=https%3A%2F%2Fzoom.us%2Frec%2Fshare%2FeY2NoHjQE1O4hmKW6dLByTpka6ZJm-QDbtEWu5zHZMg-JzUp30msW2HCZsjGRbFl.q_dm2igKWSBK5LUn), [Deployment Template](https://lf-o-ran-sc.atlassian.net/wiki/spaces/RICP/pages/136839195/RIC+Deployment+Template)] 
3. RAN Stacks
   - [Open5Gs](https://open5gs.org/open5gs/docs/guide/01-quickstart/)
   - [srsRan Project](https://github.com/srsran/srsRAN_project)
   - E2-ORAN Compliant POWDER RAN [[Repo](https://gitlab.flux.utah.edu/powderrenewpublic/srslte-ric), [srslte script](https://gitlab.flux.utah.edu/powder-profiles/oran/-/blob/master/setup-srslte.sh?ref_type=heads)]
4. Some Setup scripts from [POWDER ORAN deployment](https://gitlab.flux.utah.edu/powder-profiles/oran)
</details>

<h2 align="center">🔗🔗 Architecture 🔗🔗</h2>

</details>

<a id="ran"></a>
<details>
  <summary><strong>5G Core Network</strong></summary>
  ![5G Core Network](others/Open5GS.jpg)
</details>
 
<h2 align="center">🗓🗓 Milestone 🗓🗓</h2>