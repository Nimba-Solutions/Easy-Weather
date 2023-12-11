import { LightningElement, track, wire, api } from 'lwc';
import getWeatherObservations from '@salesforce/apex/WeatherController.getWeatherObservations';
import sendEmailToAllUsers from '@salesforce/apex/EmailSender.sendEmailToAllUsers';
import sendEmailToContacts from '@salesforce/apex/EmailSender.sendEmailToContacts';
import WEATHER_ICONS from '@salesforce/resourceUrl/WeatherIcons';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
const accFields = ["Account.BillingCity", "Account.BillingState"];

export default class WeatherTracker extends LightningElement {
    @api recordId;
    subject = 'Weather Report';
    body = undefined;
    @track isLoading = true;
    @track account = undefined;
    @track latitude;
    @track longitude;
    @track address;
    @track useAddress = false; // Default to Lat/Long input
    @track useUserLocation = false;
    @track weatherObservations;
    @track errorMessage;
    @track originalQuery = "Weather Tracker";
    @track windSpeed;
    @track temperature;
    @track humidity;
    @track weatherCondition;
    @track weatherIconUrl;
    @track icons = {
        conditions: null,
        clouds: null
    };

    @wire(getRecord, { recordId: '$recordId', fields: accFields })
    wiredAccount({ error, data }) {
        if (data) {
            console.log('WIRE SUCCESS ' + JSON.stringify(data));
            this.account = data;
            this.address = `${this.account.fields.BillingCity.value}, ${this.account.fields.BillingState.value}`;
            this.useAddress = true;
        } else if (error) {
            console.log('UAC: error ' + JSON.stringify(error));
        }
        this.isLoading = false;
    }

    connectedCallback() {
        if (this.recordId && this.recordId.startsWith('001')) {
            // If on an Account record page, wait for the account data to be loaded
            this.waitForAccountData().then(() => {
                this.getWeatherObservations();
            });
        } else {
            // If not on an Account record page, use the user's current location
            this.getUserLocation();
        }
    }

    waitForAccountData() {
        return new Promise((resolve) => {
            if (this.account) {
                // If account data is already loaded, resolve immediately
                resolve();
            } else {
                // Poll for the account data to be loaded
                const intervalId = setInterval(() => {
                    if (this.account) {
                        clearInterval(intervalId);
                        resolve();
                    }
                }, 100); // Check every 100 milliseconds
            }
        });
    }



    // Define the shareReport function
    shareReport() {
        let subject = 'Weather Report';
        let body = 'Here is the weather report:\n\n';

        // You can append weather data or any other information to the body
        if (this.weatherObservations) {
            body += 'Temperature: ' + this.temperature + '°C\n';
            body += 'Humidity: ' + this.humidity + '%\n';
            body += 'Weather Condition: ' + this.weatherCondition + '\n';
            // Add more data as needed
        }
        console.log("EMAIL TIME: ");
        console.log("Subject: ", subject);
        console.log("Body: ", body);
        if (this.recordId.startsWith('001')) {
            // If it's an Account record, call sendEmailToContacts
            sendEmailToContacts({ accountId: this.recordId, subject: subject, body: body })
                .then(result => {
                    // Handle success, if needed
                })
                .catch(error => {
                    // Handle error, if needed
                });
        } else {
            // If it's not an Account record, call sendEmailToAllUsers
            sendEmailToAllUsers({ subject: subject, body: body })
                .then(result => {
                    // Handle success, if needed
                })
                .catch(error => {
                    // Handle error, if needed
                });
        }
    }

    getUserLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                position => {
                    this.useAddress = false;
                    this.useUserLocation = true;
                    this.latitude = position.coords.latitude;
                    this.longitude = position.coords.longitude;
                    // Optionally, make a call to get weather observations
                    this.getWeatherObservations();
                    this.useUserLocation = false;
                },
                error => {
                    console.error('Error getting location', error);
                    this.errorMessage = 'Error getting location: ' + error.message;
                }
            );
        } else {
            console.error('Geolocation is not supported by this browser.');
            this.errorMessage = 'Geolocation is not supported by this browser.';
        }
    }

    handleLatLongChange(event) {
        const label = event.target.name; // Get the label from the name attribute
        this[label.toLowerCase()] = event.target.value;
    }

    handleAddressToggle(event) {
        this.useAddress = event.target.checked;
    }

    handleAddressChange(event) {
        this.address = event.target.value;
    }

    validateInputs() {
        // Validate latitude and longitude if using Lat/Long input
        if (!this.useAddress) {
            if (isNaN(this.latitude) || isNaN(this.longitude)) {
                this.errorMessage = 'Latitude and Longitude are required.';
                return false;
            }
        }

        // Validate address if using Address input
        if (this.useAddress && !this.address) {
            this.errorMessage = 'Address is required.';
            return false;
        }

        // Clear any previous error messages
        this.errorMessage = '';

        return true;
    }

    async getWeatherObservations() {
        this.isLoading = true;
        if (this.useUserLocation) {
            this.originalQuery = "Current Location";
        } else {
            this.originalQuery = this.useAddress ? this.address : `Lat: ${this.latitude}, Long: ${this.longitude}`;
        }

        // Validate inputs before making the callout
        if (this.validateInputs()) {
            try {
                const result = await getWeatherObservations({
                    location: this.address,
                    latitude: this.latitude,
                    longitude: this.longitude
                });
                const data = JSON.parse(result);
                if (data && data.weatherObservations && data.weatherObservations.length > 0) {
                    // Handle the case where there is data in weatherObservations
                    this.weatherObservations = data;
                    await this.handleWeatherResponse(data);
                } else {
                    // Handle the case where weatherObservations is empty
                    this.errorMessage = 'No Results';
                    this.weatherObservations = undefined;
                    this.windSpeed = undefined;
                    this.temperature = undefined;
                    this.humidity = undefined;
                    this.weatherCondition = undefined;
                    this.weatherIconUrl = undefined;
                }
            } catch (error) {
                console.error('Error:', error);
                this.weatherObservations = undefined;
            }
        }
        this.isLoading = false;
    }

    // Define a method to handle the weather response
    handleWeatherResponse(data) {
        // Parse the JSON response and update the component properties for display.
        if (data) {
            const observation = data.weatherObservations[0]; // Assuming there's only one observation
            console.log("Observation: ", data);
            // Extract the information you need and set component properties.
            this.windSpeed = observation.windSpeed; // Replace with actual data
            this.temperature = observation.temperature; // Replace with actual data
            this.humidity = observation.humidity; // Replace with actual data
            this.weatherCondition = observation.weatherCondition === "n/a" ? "Not Provided" : observation.weatherCondition;

            const icons = getWeatherIconUrls(observation, this.weatherIconMappings);
            this.icons.conditions = icons.conditions; // Update conditions icon URL
            this.icons.clouds = icons.clouds; // Update clouds icon URL

            // Clear any previous error messages
            this.errorMessage = '';
        }
    }

    get noWeatherData() {
        return this.icons.conditions === null && this.icons.clouds === null;
    }

    weatherIconMappings = {
        "conditionIcons": {
            "DZ": "wi-sprinkle",
            "RA": "wi-rain",
            "SN": "wi-snow",
            "SG": "wi-snow",
            "IC": "wi-snowflake-cold",
            "PL": "wi-sleet",
            "GR": "wi-hail",
            "GS": "wi-sleet",
            "UP": "wi-na",
            "BR": "wi-fog",
            "FG": "wi-fog",
            "FU": "wi-smoke",
            "VA": "wi-volcano",
            "SA": "wi-sandstorm",
            "HZ": "wi-day-haze",
            "PY": "wi-spray",
            "DU": "wi-dust",
            "SQ": "wi-strong-wind",
            "SS": "wi-sandstorm",
            "DS": "wi-dust",
            "PO": "wi-tornado",
            "FC": "wi-tornado",
            "+FC": "wi-hurricane",
            "-": "wi-cloud",
            "+": "wi-cloudy-gusts",
            "VC": "wi-cloud",
            "MI": "wi-fog",
            "BC": "wi-cloud",
            "SH": "wi-showers",
            "PR": "wi-cloudy",
            "TS": "wi-thunderstorm",
            "BL": "wi-strong-wind",
            "DR": "wi-cloudy-windy",
            "SN": "wi-snowflake-cold"
        },
        "cloudIcons": {
            "SKC": "wi-day-sunny",
            "CLR": "wi-night-clear",
            "FEW": "wi-cloud",
            "SCT": "wi-cloudy",
            "BKN": "wi-cloudy",
            "OVC": "wi-cloudy-gusts",
            "CAVOK": "wi-day-sunny-overcast",
            "NCD": "wi-night-clear",
            "NSC": "wi-cloudy",
            "VV": "wi-fog"
        }
    };

}

// Standalone function to get weather icon urls
function getWeatherIconUrls(observation, weatherIconMappings) {
    console.log("Getting Weather Icons...");

    const conditionIcon = weatherIconMappings.conditionIcons[observation.weatherCondition];
    const cloudIcon = weatherIconMappings.cloudIcons[observation.cloudsCode];

    console.log("conditionIcon...", conditionIcon);
    console.log("cloudIcon...", cloudIcon);

    const conditionIconUrl = conditionIcon !== undefined ? `${WEATHER_ICONS}/wi-icons-svg/${conditionIcon}.svg` : null;
    const cloudIconUrl = cloudIcon !== undefined ? `${WEATHER_ICONS}/wi-icons-svg/${cloudIcon}.svg` : null;

    return {
        conditions: conditionIconUrl,
        clouds: cloudIconUrl
    };
}