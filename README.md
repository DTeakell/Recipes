## Recipes
### Summary
A recipe app that shows various recipes from an API. Made using SwiftUI

### Screenshots
<img src= "./Screenshots and Media/Recipes-Dark.png" alt= "App Screenshot" width="200"> <img src= "./Screenshots and Media/Recipes-Light.png" alt="App Screenshot" width="200">

### Focus Areas
I chose to prioritize making sure network utilization was as low as possible, caching images and saving the JSON data directly to the disk using URLSession and FileManager.

I also chose to prioritize simplicity and minimalism with the design, making a simple list of recipes and allowing the user to open the YouTube link to view how to make the recipe.

Finally, since I am new to unit testing and caching different types of data, focusing on aquiring more skill and knowledge on the topic was a high priority during this project.

### Time Spent
I allocated most of my time implementing efficient network usage and debugging the JSON data. Most of the time was spent learning more about unit testing and debugging JSON, caching uaing FileManager, and UI errors. I also descided to make a simple UI to make the app as light as possible to avoid slowdowns.

### Trade-Offs and Decisions
Since I am new to unit testing and caching data, I decided to allocate more of my time to debugging and aquiring knowledge on topics I thought were most important. I had a lot of ideas on how I could make the UI more appealing and accessible, such as making collapsible sections or making horizontal ScrollViews within the sections to better make use of space, and implementing Dynamic Type and accessibility labels for VoiceOver features. I also wanted to use SwiftData instead of File Manager, since I have experience using SwiftData. But since adoption is still rather new, and not the industry standard, I decided to save the data directly to disk using File Manager to have a simple, reliable cache.

### Weakest Part
I believe the weakest part is the UI. As stated in my **trade-offs**, I wanted to implement more features, but because aquiring unit testing and debugging skills were a higher priority, I wasn't able to implement as many of the features I would have liked to.

### Additional Information
This has been a tremendous learing experience for me, and I will continue to improve this project even after submission to showcase my skills and learning progress!
