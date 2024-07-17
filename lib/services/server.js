const express = require('express');
const multer = require('multer');
const {
  GoogleGenerativeAI,
  HarmCategory,
  HarmBlockThreshold,
} = require("@google/generative-ai");
const { GoogleAIFileManager } = require("@google/generative-ai/server");

const app = express();
const port = 3000;

const apiKey = process.env.GEMINI_API_KEY || 'YOUR_API_KEY_HERE';
const genAI = new GoogleGenerativeAI(apiKey);
const fileManager = new GoogleAIFileManager(apiKey);

const upload = multer({ dest: 'uploads/' });

async function uploadToGemini(path, mimeType) {
  const uploadResult = await fileManager.uploadFile(path, {
    mimeType,
    displayName: path,
  });
  const file = uploadResult.file;
  console.log(`Uploaded file ${file.displayName} as: ${file.name}`);
  return file;
}

const model = genAI.getGenerativeModel({
  model: "gemini-1.5-flash",
});

const generationConfig = {
  temperature: 1,
  topP: 0.95,
  topK: 64,
  maxOutputTokens: 8192,
  responseMimeType: "text/plain",
};

app.post('/scan-ticket', upload.single('ticket'), async (req, res) => {
  try {
    const filePath = req.file.path;
    const mimeType = req.file.mimetype;

    const file = await uploadToGemini(filePath, mimeType);

    const chatSession = model.startChat({
      generationConfig,
      history: [
        {
          role: "user",
          parts: [
            { text: "Tell me what movie name is it, what is the date and price of the movie ticket" },
          ],
        },
        {
          role: "model",
          parts: [
            { text: "Please give me some information about the movie! For example, you could tell me:\n\n* **What the movie is about** (e.g., \"a superhero movie\", \"a romantic comedy set in Paris\")\n* **Who stars in it** (e.g., \"Tom Hanks\", \"Zendaya\")\n* **Any other details you remember** (e.g., \"I saw it in the 90s\", \"It had a really catchy song on the soundtrack\") \n\nThe more information you give me, the better chance I have of figuring out the movie you're thinking of! 😊 \n" },
          ],
        },
        {
          role: "user",
          parts: [
            {
              fileData: {
                mimeType: file.mimeType,
                fileUri: file.uri,
              },
            },
            { text: "Tell me what movie name is it, what is the date and price of the movie ticket, and give me in json, if the movie name is incomplete, complete the name for me" },
          ],
        },
        {
          role: "model",
          parts: [
            { text: "```json\n{\n  \"movie_name\": \"MAZE RUNNER: THE SCORCH TRIALS\",\n  \"date\": \"22 SEP 2015\",\n  \"price\": \"8.50\"\n}\n```" },
          ],
        },
      ],
    });

    const result = await chatSession.sendMessage("INSERT_INPUT_HERE");
    res.json({ data: result.response.text() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to process the ticket' });
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
