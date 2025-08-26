const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
const db = admin.firestore();

// Replace with your channel ID and API key
const CHANNEL_ID = "UCFR5X_YpP25n2y6CFOw4ILQ"; // Hendry Tech Channel
const API_KEY = "AIzaSyDwUtd86DXIabwvDVkXpjqQ65pnrFJBHm8";

// Cloud Function to fetch latest videos and save them to Firestore
exports.fetchYouTubeVideos = functions.pubsub
    .schedule("every 1 hours") // ⏰ Run once every hour
    .onRun(async () => {
      const url = `https://www.googleapis.com/youtube/v3/search?key=${API_KEY}&channelId=${CHANNEL_ID}&part=snippet,id&order=date&maxResults=10`;

      try {
        const res = await fetch(url);
        const data = await res.json();

        if (!data.items) {
          console.error("YouTube API returned no items:", data);
          return null;
        }

        const batch = db.batch();
        data.items.forEach((item) => {
          if (item.id.kind === "youtube#video") {
            const videoId = item.id.videoId;
            const videoData = {
              videoId,
              title: item.snippet.title,
              description: item.snippet.description,
              thumbnailUrl: item.snippet.thumbnails.high.url,
              publishedAt: item.snippet.publishedAt,
            };
            const ref = db.collection("videos").doc(videoId);
            batch.set(ref, videoData, {merge: true});
          }
        });

        await batch.commit();
        console.log("✅ Videos updated in Firestore");
        return null;
      } catch (error) {
        console.error("❌ Error fetching videos:", error);
        return null;
      }
    });
