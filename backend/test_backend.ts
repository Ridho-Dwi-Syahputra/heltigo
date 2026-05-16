process.env.DATABASE_URL="mysql://root:@localhost:3306/heltigo";
process.env.JWT_SECRET="supersecretjwtkey_minimum_32_chars_long";
process.env.ML_SERVICE_URL="http://localhost:8001";
process.env.ML_SERVICE_KEY="dev-shared-secret-change-in-prod";

import { MlService } from './src/services/ml.service';

async function testConnection() {
  console.log("Testing connection to ML Service...");
  try {
    const res = await MlService.predictFoodScan({ image_base64: "dummy" });
    console.log("Success! Received response:", res);
  } catch (err: any) {
    if (err.response) {
      console.error("ML Service replied with error (this is expected since image is dummy):", err.response.data);
    } else {
      console.error("Error connecting to ML service:", err.message);
    }
  }
}

testConnection();
