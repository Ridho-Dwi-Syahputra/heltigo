const axios = require('axios');

async function testIntegration() {
    const baseURL = 'http://localhost:3000/api/v1';
    
    try {
        console.log("1. Registering user...");
        const registerRes = await axios.post(`${baseURL}/auth/register`, {
            email: `test_${Date.now()}@test.com`,
            password: 'Password123!',
            name: 'Integration Tester'
        });
        console.log("Register response:", registerRes.data);
        const token = registerRes.data.accessToken;
        console.log("Token received.");

        console.log("2. Creating health profile...");
        await axios.post(`${baseURL}/user/health-profile`, {
            age: 25,
            gender: 'M',
            heightCm: 175,
            weightKg: 80,
            fitnessLevel: 'BEGINNER',
            goal: 'WEIGHT_LOSS',
            workoutMode: 'GYM',
            targetWeightKg: 70,
            dietaryRestrictions: ['HALAL'],
            healthConditions: [],
            availableDaysPerWeek: 4,
            sessionDurationMin: 60,
            budgetPerDayIdr: 50000
        }, {
            headers: { Authorization: `Bearer ${token}` }
        });
        console.log("Health profile created.");

        console.log("3. Generating plan (Backend -> ML -> Gemini)...");
        const planRes = await axios.post(`${baseURL}/plan/generate`, {}, {
            headers: { Authorization: `Bearer ${token}` }
        });
        
        console.log("Plan generated successfully!");
        console.log(JSON.stringify(planRes.data.data, null, 2));

    } catch (error) {
        console.error("Test failed:");
        if (error.response) {
            console.error(JSON.stringify(error.response.data, null, 2));
        } else {
            console.error(error.message);
        }
    }
}

testIntegration();
