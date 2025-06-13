# TAKE-U DELIVERY SERVICE

## AUTHENTICATION ENDPOINTS

### 1. User Signup
Endpoint: `POST /api/auth/user/signup`
#### Request Parameters:

```json
{
  "phone_number": "string", 
  "email": "string",
  "first_name": "string",
  "last_name": "string",
  "password": "string"
}
```

#### Response:
```json
{
  "status": "success",
  "message": "User registered successfully. OTP sent to phone number",
  "data": {
    "user_id": "string",
    "email": "string",
    "phone_number": "string"
  }
}
```
Status Codes
- 201: Created
- 400: Bad Request (Invalid input)
- 409: Conflict (Email/Phone already exists)

### 2. Driver Signup
Endpoint: `POST /api/auth/driver/signup`

**Request Body**
```json
{
  "phone_number": "string", 
  "email": "string",
  "first_name": "string",
  "last_name": "string",
  "password": "string",
  "gender": "string",
  "address": "string",
  "profile_photo": "file",
  "national_id_number": "string",
  "national_id_image": "file",
  "drivers_license": "file"
}
```

**Response**
```json
{
  "status": "success",
  "message": "Driver registered successfully. OTP sent to phone number",
  "data": {
    "driver_id": "string",
    "email": "string",
    "phone_number": "string"
  }
}
```

Status Codes
- 201: Created
- 400: Bad Request (Invalid input)
- 409: Conflict (Email/Phone already exists)

### 3. Verify OTP
**Endpoint:** `POST /api/auth/<driver or client>/verify-otp`

**Request Body**
```json
{
  "phone_number": "string",
  "otp_code": "string"
}
```

##### Response:
```json
{
  "status": "success",
  "message": "Phone number verified successfully",
  "data": {
    "access_token": "string",
    "refresh_token": "string",
    "user_type": "string", // "user" or "driver"
    "user_profile": {
      // For user type = "user"
      "user_id": "string",
      "email": "string",
      "phone_number": "string",
      "first_name": "string",
      "last_name": "string",
      "wallet_balance": "number"
    },
    "driver_profile": {
      // For user type = "driver"
      "driver_id": "string",
      "email": "string",
      "phone_number": "string",
      "first_name": "string",
      "last_name": "string",
      "gender": "string",
      "address": "string",
      "profile_photo_url": "string",
      "national_id_number": "string",
      "wallet_balance": "number",
      "rating": "number"
    }
  }
}
```
Status Codes:
- 200: OK
- 400: Bad Request (Invalid OTP)
- 410: Gone (OTP expired)

------------------------------------------------

#### 4. User Login
**Endpoint:** `POST /api/auth/client/login`

##### Request Parameters
```json
{
  "login_id": "string", // Can be email or phone number
  "password": "string"
}
```


**Response:**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "access_token": "string",
    "refresh_token": "string",
    "user_type": "user",
    "user_id": "string",
    "user_profile": {
      "user_id": "string",
      "email": "string",
      "phone_number": "string",
      "first_name": "string",
      "last_name": "string",
      "wallet_balance": "number"
    }
  }
}
```

**Status Codes:**
- 200: OK
- 401: Unauthorized (Invalid credentials)
- 403: Forbidden (Account not verified)

---------------------------------

#### 5. Driver Login
**Endpoint:** `POST /api/auth/driver/login`

**Request Parameters:**
```json
{
  "login_id": "string", // Can be email or phone number
  "password": "string"
}
```


**Response:**

```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "access_token": "string",
    "refresh_token": "string",
    "user_type": "driver",
    "driver_id": "string",
    "driver_profile": {
      "driver_id": "string",
      "email": "string",
      "phone_number": "string",
      "first_name": "string",
      "last_name": "string",
      "gender": "string",
      "address": "string",
      "profile_photo_url": "string",
      "national_id_number": "string",
      "rating": "number",
      "active_vehicle": {
        "vehicle_id": "string",
        "vehicle_type": "string",
        "model": "string",
        "license_plate_number": "string",
        "year": "string",
        "color": "string"
      }
    }
  }
}
```

**Status Codes:**
- 200: OK
- 401: Unauthorized (Invalid credentials)
- 403: Forbidden (Account not verified)

-------------------------------------------------

## 6. Request Password Reset
**Endpoint:** `POST /api/auth/request-password-reset`

**Request Parameters:**
```json
{
  "login_id": "string" // email or phone (9 digits)
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Password reset link sent to email" // or send OTP to phone number
}
```

**Status Codes:**
- 200: OK
- 404: Not Found (Email not registered / Phone number not registered)

## 7. Reset Password
### 7a. Reset Password Email
**Endpoint:** `POST /api/auth/reset-password-email`

**Request Parameters:**
```json
{
  "token": "string",
  "new_password": "string"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Password reset successful"
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid token or password)
- 410: Gone (Token expired)

### 7b. Reset Password Phone Number
**Endpoint:** `POST /api/auth/reset-password-phone`

**Request Parameters:**
```json
{
  "otp_token": "number",
  "new_password": "string"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Password reset successful"
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid token or password)
- 410: Gone (Token expired)

## 8. Change Password
**Endpoint:** `PUT /api/auth/change-password`

**Request Parameters:**
**Authorization: Bearer token**
```json
{
  "current_password": "string",
  "new_password": "string"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Password changed successfully"
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid password format)
- 401: Unauthorized (Incorrect current password)
- 404: Not Found (User not found)


-------------------------------------------------------------------------------------------------------------------

# User Management Endpoints

## 1. Get User Profile
**Endpoint:** `GET /api/users/profile`

**Query Parameters:**
- `email`: Email of the user

**Response:**
```json
{
  "status": "success",
  "data": {
    "user_id": "string",
    "email": "string",
    "phone_number": "string",
    "first_name": "string",
    "last_name": "string",
    "wallet_balance": "number"
  }
}
```


**Status Codes:**
- 200: OK
- 404: Not Found (User not found)

## 2. Update User Profile
**Endpoint:** `PUT /api/users/profile`

**Query Parameters:**
- `email`: Email of the user

**Request Parameters:**
```json
{
  "first_name": "string", // optional
  "last_name": "string", // optional
  "phone_number": "string" // optional
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Profile updated successfully",
  "data": {
    "user_id": "string",
    "email": "string",
    "phone_number": "string",
    "first_name": "string",
    "last_name": "string"
  }
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid input)
- 404: Not Found (User not found)
- 409: Conflict (Phone already exists)

## 3. Get User Deliveries
**Endpoint:** `GET /api/client/<client_id>/deliveries`

**Query Parameters:**
- `status`: Filter by delivery status (optional)
- `pageNumner`: Page number (optional, default: 1)
- `pageSize`: Items per page (optional, default: 10)
- `sort`: Sort items

**Path Variable**
- `client_id` : Email of the user

**Response:**
```json
{
  "status": "success",
  "data": {
    "deliveries": [
      {
        "delivery_id": "string",
        "delivery_type": "string",
        "price": "number",
        "sensitivity": "string", // premium or basic
        "delivery_status": "string",
        "payment_status": "string",
        "created_at": "string",
        "pickup_latitude": "number",
        "pickup_longitude": "number",
        "pickup_location": "string", // readable address
        "pickup_contact_name": "string",
        "pickup_contact_phone": "string",
        "drop_off_latitude": "number",
        "drop_off_longitude": "number",
        "drop_off_location": "string", // readable address
        "drop_off_contact_name": "string",
        "drop_off_contact_phone": "string",
        "delivery_instructions": "string", // optional
        "parcel_description": "string", // optional
        "quantity": "number", // optional
        "weight": "number", // optional
        "height": "number", // optional
        "prefered_currency": "string",
        "vehicle_type": "string",
        "payment_method": "string", 
        "delivery_date": "string", // required if scheduled
        "delivery_time": "string", // required if scheduled
        "pickup_image_url": "string", // nullable depending on delivery status
        "driver": {
          "driver_id": "string",
          "first_name": "string",
          "last_name": "string",
          "profile_photo_url": "string",
          "rating": "number",
          "vehicle": {
            "vehicle_type": "string",
            "model": "string",
            "color": "string",
            "license_plate_number": "string"
          }
        } // null if no driver assigned
      }
    ],
    "pagination": {
      "total": "number",
      "totalPages": "number",
      "pageNumber": "number",
      "pageSize": "number"
    }
  }
}
```


**Status Codes:**
- 200: OK
- 404: Not Found (User not found)

## 4. Get User Delivery History
**Endpoint:** `GET /api/client/<client_id>/delivery-history`

**Query Parameters:**
- `page`: Page number (optional, default: 1)
- `limit`: Items per page (optional, default: 10)
- `from_date`: Filter from date (optional, format: YYYY-MM-DD)
- `to_date`: Filter to date (optional, format: YYYY-MM-DD)

**Path Variable**
- `client_id`: Email of the user

**Response:**
```json
{
  "status": "success",
  "data": {
    "deliveries": [
      {
        "delivery_id": "string",
        "delivery_type": "string",
        "pickup_location": "string",
        "drop_off_location": "string",
        "price": "number",
        "created_at": "string",
        "completed_at": "string",
        "driver": {
          "driver_id": "string",
          "first_name": "string",
          "last_name": "string",
          "email": "string",
          "profile_photo_url": "string",
          "rating": "number"
        },
        "rating": {
          "rating": "number",
          "comment": "string"
        } // null if not rated
      }
    ],
    "pagination": {
      "total": "number",
      "totalPages": "number",
      "pageNumber": "number",
      "pageSize": "number"
    },
    "summary": {
      "total_deliveries": "number",
      "total_spent": "number",
      "average_rating_given": "number"
    }
  }
}
```


**Status Codes:**
- 200: OK
- 404: Not Found (User not found)

---------------------------------------------------------------------------------------------------------------

Here is the Driver Management section:

# Driver Management Endpoints

## 1. Get Driver Profile
**Endpoint:** `GET /api/drivers/<driver_id>/profile`

**Path Parameters:**
- `driver_id`: Email of the driver

**Response:**
```json
{
  "status": "success",
  "data": {
    "driver_id": "string",
    "email": "string",
    "phone_number": "string",
    "first_name": "string",
    "last_name": "string",
    "gender": "string",
    "address": "string",
    "profile_photo_url": "string",
    "national_id_number": "string",
    "wallet_balance": "number",
    "rating": "number",
    "active_vehicle": {
      "vehicle_id": "string",
      "vehicle_type": "string",
      "model": "string",
      "license_plate_number": "string",
      "year": "string",
      "color": "string"
    }
  }
}
```

**Status Codes:**
- 200: OK
- 404: Not Found (Driver not found)

## 2. Update Driver Profile
**Endpoint:** `PUT /api/drivers/<driver_id>/profile`

**Path Parameters:**
- `driver_id`: Email of the driver

**Request Parameters:**
```json
{
  "first_name": "string", // optional
  "last_name": "string", // optional
  "address": "string", // optional
  "profile_photo": "file" // optional
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Profile updated successfully",
  "data": {
    "driver_id": "string",
    "first_name": "string",
    "last_name": "string",
    "address": "string",
    "profile_photo_url": "string"
  }
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid input)
- 404: Not Found (Driver not found)

## 3. Get Open Deliveries
**Endpoint:** `GET /api/drivers/open/deliveries`

**Query Parameters:**
- `page`: Page number (optional, default: 1)
- `limit`: Items per page (optional, default: 10)

**Response:**
```json
{
  "status": "success",
  "data": {
    "deliveries": [
      {
        "delivery_id": "string",
        "delivery_type": "string", 
        "sensitivity": "string", // premium or basic
        "pickup_location": "string",
        "drop_off_location": "string",
        "pickup_latitude": "number",
        "pickup_longitude": "number",
        "drop_off_latitude": "number",
        "drop_off_longitude": "number",
        "vehicle_type": "string",
        "price": "number",
        "distance": "number", // in km
        "estimated_duration": "number", // in minutes
        "pickup_date": "datetime", 
        "created_at": "string"
      }
    ],
    "pagination": {
      "total": "number",
      "pages": "number",
      "page": "number",
      "limit": "number"
    }
  }
}
```

**Status Codes:**
- 200: OK
- 404: Not Found (Driver not found)

## 4. Get Driver's Deliveries
**Endpoint:** `GET /api/drivers/<driver_id>/assigned-deliveries`

**Query Parameters:**
- `status`: Filter by delivery status (optional)
- `page`: Page number (optional, default: 1)
- `limit`: Items per page (optional, default: 10)

**Path Variables:**


**Response:**
```json
{
  "status": "success",
  "data": {
    "deliveries": [
      {
        "delivery_id": "string",
        "delivery_type": "string",
        "price": "number",
        "sensitivity": "string", // premium or basic
        "delivery_status": "string",
        "payment_status": "string",
        "created_at": "string",
        "pickup_latitude": "number",
        "pickup_longitude": "number",
        "pickup_location": "string", // readable address
        "pickup_contact_name": "string",
        "pickup_contact_phone": "string",
        "drop_off_latitude": "number",
        "drop_off_longitude": "number",
        "drop_off_location": "string", // readable address
        "drop_off_contact_name": "string",
        "drop_off_contact_phone": "string",
        "delivery_instructions": "string", // optional
        "parcel_description": "string", // optional
        "quantity": "number", // optional
        "weight": "number", // optional
        "height": "number", // optional
        "prefered_currency": "string",
        "vehicle_type": "string",
        "payment_method": "string", 
        "delivery_date": "string", // required if scheduled
        "delivery_time": "string", // required if scheduled
        "pickup_image_url": "string", // nullable depending on delivery status
        "user": {
          "clinet_id": "string",
          "phone_number": "string",
          "email": "string",
          "first_name": "string",
          "last_name": "string"
        } // null if no driver assigned
      }
    ],
    "pagination": {
      "total": "number",
      "totalPages": "number",
      "pageNumber": "number",
      "pageSize": "number"
    }
  }
}
```

**Status Codes:**
- 200: OK
- 404: Not Found (Driver not found)

## 5. Get Driver Delivery History
**Endpoint:** `GET /api/drivers/<driver_id>/delivery-history`

**Query Parameters:**
- `page`: Page number (optional, default: 1)
- `limit`: Items per page (optional, default: 10)
- `from_date`: Filter from date (optional, format: YYYY-MM-DD)
- `to_date`: Filter to date (optional, format: YYYY-MM-DD)

**Path Parameters**
- `email`: Email of the driver

**Response:**
```json
{
  "status": "success",
  "data": {
    "deliveries": [
      {
        "delivery_id": "string",
        "delivery_type": "string",
        "pickup_location": "string",
        "drop_off_location": "string",
        "price": "number",
        "payment_method": "string",
        "created_at": "string",
        "completed_at": "string",
        "user": {
          "user_id": "string",
          "first_name": "string",
          "last_name": "string",
          "email": "string"
        },
        "rating": {
          "rating": "number",
          "comment": "string"
        } // null if not rated
      }
    ],
    "pagination": {
      "total": "number",
      "pages": "number",
      "page": "number",
      "limit": "number"
    },
    "summary": {
      "total_deliveries": "number",
      "total_earnings": "number",
      "average_rating_received": "number"
    }
  }
}
```

**Status Codes:**
- 200: OK
- 404: Not Found (Driver not found)

## 6. Accept Delivery
**Endpoint:** `POST /api/drivers/deliveries/accept`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Request Parameters:**
```json
{
  "driver_id": "number", // Email of the driver
  "delivery_id": "number",
  "latitude": "number",
  "longitude": "number"
}
```

**Response:**
```json
{
    "status": "success",
    "message": "Delivery accepted successfully"
}
```


**Status Codes:**
- 200: OK
- 400: Bad Request (Delivery not in pending status)
- 404: Not Found (Delivery or driver not found)

## 7. Pick Up Delivery
**Endpoint:** `POST /api/drivers/deliveries/{delivery_id}/pickup`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Request Parameters:**
```json
{
    "email": "string",
    "latitude": "number",
    "longitude": "number",
    "pickup_image": "file"
}
```



**Response:**
```json
{
    "status": "success",
    "message": "Delivery picked up successfully",
    "data": {
        "delivery_status": "picked",
        "approval_otp": "string"
    }
}
```


**Status Codes:**
- 200: OK
- 400: Bad Request (Delivery not in active status)
- 403: Forbidden (Not authorized to update this delivery)
- 404: Not Found (Delivery or driver not found)



----------------------------------------------------------------------------------------------------------------


Here is the next section on Delivery Management:

# Delivery Management Endpoints

## 1. Calculate Delivery Price
**Endpoint:** `POST /api/deliveries/calculate-price`

**Request Parameters:**
```json
{
    "pickup_latitude": "number",
    "pickup_longitude": "number",
    "drop_off_latitude": "number",
    "drop_off_longitude": "number",
    "vehicle_type": "string",
    "weight": "number",
    "height": "number",
    "delivery_type": "string"
}
```


**Response:**
```json
{
    "status": "success",
    "data": {
        "base_price": "number",
        "distance_fee": "number",
        "vehicle_type_fee": "number",
        "weight_fee": "number",
        "height_fee": "number",
        "scheduled_fee": "number",
        "total_price": "number"
    }
}
```


**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid input)

## 2. Create Delivery
**Endpoint:** `POST /api/deliveries`

**Request Parameters:**
```json
{
  "email": "string",
  "delivery_type": "string",
  "pickup_latitude": "number",
  "pickup_longitude": "number",
  "pickup_location": "string",
  "pickup_contact_name": "string",
  "pickup_contact_phone": "string",
  "drop_off_latitude": "number",
  "drop_off_longitude": "number",
  "drop_off_location": "string",
  "drop_off_contact_name": "string",
  "drop_off_contact_phone": "string",
  "delivery_instructions": "string",
  "parcel_description": "string",
  "quantity": "number",
  "weight": "number",
  "height": "number",
  "vehicle_type": "string",
  "payment_method": "string",
  "delivery_date": "string",
  "delivery_time": "string"
}
```


**Response:**
```json
{
    "status": "success",
    "message": "Delivery created successfully",
    "data": {
        "delivery_id": "string",
        "price": "number",
        "payment_completed": "boolean",
        "delivery_status": "pending",
        "created_at": "string"
    }
}
```

**Status Codes:**
- 201: Created
- 400: Bad Request (Invalid input or insufficient wallet balance)
- 402: Payment Required (Payment failed)
- 404: Not Found (User not found)

## 3. Get Delivery Details
**Endpoint:** `GET /api/deliveries/{delivery_id}`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Query Parameters:**
- `email`: Email of the user or driver (to validate access rights)

**Response:**
```json
{
  "status": "success",
  "data": {
    "delivery_id": "string",
    "delivery_type": "string",
    "pickup_latitude": "number",
    "pickup_longitude": "number",
    "pickup_location": "string",
    "pickup_contact_name": "string",
    "pickup_contact_phone": "string",
    "drop_off_latitude": "number",
    "drop_off_longitude": "number",
    "drop_off_location": "string",
    "drop_off_contact_name": "string",
    "drop_off_contact_phone": "string",
    "delivery_instructions": "string",
    "parcel_description": "string",
    "quantity": "number",
    "weight": "number",
    "height": "number",
    "vehicle_type": "string",
    "payment_method": "string",
    "delivery_date": "string",
    "delivery_time": "string",
    "price": "number",
    "delivery_status": "string",
    "payment_completed": "boolean",
    "parcel_image_url": "string", // null if not picked up yet
    "approval_otp": "string", // only shown to driver when status is "picked"
    "created_at": "string",
    "driver": {
      "driver_id": "string",
      "first_name": "string",
      "last_name": "string",
      "email": "string",
      "phone_number": "string",
      "profile_photo_url": "string",
      "rating": "number",
      "latitude": "number", // current location
      "longitude": "number", // current location
      "vehicle": {
        "vehicle_type": "string",
        "model": "string",
        "color": "string",
        "license_plate_number": "string"
      }
    },
    "user": {
      "user_id": "string",
      "first_name": "string",
      "last_name": "string",
      "email": "string",
      "phone_number": "string"
    },
    "rating": {
      "rating": "number",
      "comment": "string"
    } // null if not rated yet
  }
}
```

**Status Codes:**
- 200: OK
- 403: Forbidden (Not authorized to view this delivery)
- 404: Not Found

## 4. Cancel Delivery
**Endpoint:** `POST /api/deliveries/{delivery_id}/cancel`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Request Parameters:**
```json
{
  "email": "string", // Email of the user
  "cancellation_reason": "string" // optional
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Delivery cancelled successfully"
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Cannot cancel delivery in current status)
- 403: Forbidden (Not authorized to cancel this delivery)
- 404: Not Found


Here's the next part of the Delivery Management section:

# Delivery Management Endpoints (continued)

## 5. Get Available Drivers
**Endpoint:** `GET /api/deliveries/{delivery_id}/available-drivers`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Query Parameters:**
- `email`: Email of the user (to validate access rights)

**Response:**
```json
{
  "status": "success",
  "data": {
    "drivers": [
      {
        "driver_id": "string",
        "first_name": "string",
        "last_name": "string",
        "email": "string",
        "profile_photo_url": "string",
        "rating": "number",
        "latitude": "number",
        "longitude": "number",
        "distance": "number", // distance from pickup in km
        "estimated_arrival_time": "number", // in minutes
        "vehicle": {
          "vehicle_type": "string",
          "model": "string",
          "color": "string",
          "license_plate_number": "string"
        }
      }
    ]
  }
}
```

**Status Codes:**
- 200: OK
- 403: Forbidden (Not authorized to view drivers for this delivery)
- 404: Not Found

## 6. Select Driver
**Endpoint:** `POST /api/deliveries/{delivery_id}/select-driver/{driver_id}`

**Path Parameters:**
- `delivery_id`: ID of the delivery
- `driver_id`: ID of the delivery


**Response:**
```json
{
  "status": "success",
  "message": "Driver selected successfully",
  "data": {
    "delivery_status": "active",
    "driver": {
      "driver_id": "string",
      "first_name": "string",
      "last_name": "string",
      "email": "string",
      "phone_number": "string",
      "profile_photo_url": "string",
      "rating": "number",
      "vehicle": {
        "vehicle_type": "string",
        "model": "string",
        "color": "string",
        "license_plate_number": "string"
      }
    }
  }
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Driver not available or invalid driver)
- 403: Forbidden (Not authorized to select driver for this delivery)
- 404: Not Found

## 6a. Get delivery available drivers
**Endpoint:** `POST /api/deliveries/{delivery_id}/available-driver`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Request Parameters:**

list of drivers (latitude, longitude, avaerage-rating, created-at) and driver profile

**Response:**
```json
{
  "status": "success",
  "message": "Driver selected successfully",
  "data": {
    "delivery_status": "active",
    "driver": {
      "driver_id": "string",
      "first_name": "string",
      "last_name": "string",
      "email": "string",
      "phone_number": "string",
      "profile_photo_url": "string",
      "rating": "number",
      "vehicle": {
        "vehicle_type": "string",
        "model": "string",
        "color": "string",
        "license_plate_number": "string"
      }
    }
  }
}
```


**Status Codes:**
- 200: OK
- 400: Bad Request (Driver not available or invalid driver)
- 403: Forbidden (Not authorized to select driver for this delivery)
- 404: Not Found

## 7. Get Driver Location
**Endpoint:** `GET /api/deliveries/{delivery_id}/driver-location`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Query Parameters:**
- `email`: Email of the user (to validate access rights)

**Response:**
```json
{
  "status": "success",
  "data": {
    "latitude": "number",
    "longitude": "number",
    "updated_at": "string"
  }
}
```


**Status Codes:**
- 200: OK
- 403: Forbidden (Not authorized to view this delivery)
- 404: Not Found (Delivery not found or no driver assigned)

## 8. Complete Delivery (Driver)
**Endpoint:** `POST /api/drivers/deliveries/{delivery_id}/complete`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Request Parameters:**
```json
{
  "email": "string", // Email of the driver
  "latitude": "number",
  "longitude": "number",
  "approval_otp": "string" // OTP received from recipient
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Delivery completed successfully",
  "data": {
    "delivery_status": "completed"
  }
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Delivery not in picked status)
- 401: Unauthorized (Invalid OTP)
- 403: Forbidden (Not authorized to update this delivery)
- 404: Not Found (Delivery or driver not found)

## 9. Rate Delivery
**Endpoint:** `POST /api/deliveries/{delivery_id}/rate`

**Path Parameters:**
- `delivery_id`: ID of the delivery

**Request Parameters:**
```json
{
  "email": "string", // Email of the user rating the delivery
  "rating": "number", // 1-5
  "comment": "string" // optional
}
```


**Response:**
```json
{
  "status": "success",
  "message": "Delivery rated successfully"
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid rating or delivery not completed)
- 403: Forbidden (Not authorized to rate this delivery)
- 404: Not Found
- 409: Conflict (Already rated)



------------------------------------------------------------------------------------------------------------


Here's the section on Wallet Management:

# Wallet Management Endpoints

## 1. Get Wallet Balance
**Endpoint:** `GET /api/wallet/balance`

**Query Parameters:**
- `email`: Email of the user or driver
- `user_type`: Type of user ("user" or "driver")

**Response:**
```json
{
  "status": "success",
  "data": {
    "balance": "number"
  }
}
```


**Status Codes:**
- 200: OK
- 404: Not Found (User/Driver not found)

## 2. Get Transaction History
**Endpoint:** `GET /api/wallet/transaction/{userId}`

**Path Variable**
- `userID`: ID of the user or driver

**Query Parameters:**
- `user_type`: Type of user ("user" or "driver")
- `transaction_type`: Filter by transaction type (optional)
- `page`: Page number (optional, default: 1)
- `limit`: Items per page (optional, default: 10)

**Response:**
```json
{
  "status": "success",
  "data": {
    "transactions": [
      {
        "transaction_id": "string",
        "transaction_type": "string",
        "amount": "number",
        "title": "string",
        "date_time": "string"
      }
    ],
    "pagination": {
      "total": "number",
      "pages": "number",
      "page": "number",
      "limit": "number"
    }
  }
}
```

**Status Codes:**
- 200: OK
- 404: Not Found (User/Driver not found)

## 3. Add Funds to Wallet
**Endpoint:** `POST /api/wallet/add-funds`

**Request Parameters:**
```json
{
  "email": "string", // Email of the user or driver
  "user_type": "string", // "user" or "driver"
  "amount": "number",
  "payment_method": "string" // "card", "bank_transfer", etc.
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Payment initiated",
  "data": {
    "payment_url": "string", // URL to redirect to payment gateway
    "transaction_id": "string"
  }
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid amount or payment method)
- 404: Not Found (User/Driver not found)

## 4. Withdraw Funds (Driver)
**Endpoint:** `POST /api/drivers/wallet/withdraw`

**Request Parameters:**
```json
{
  "email": "string", // Email of the driver
  "amount": "number",
  "payment_method": "string", // "bank_transfer", "mobile_money", etc.
  "payment_details": {
    // Details specific to the payment method
    "account_number": "string",
    "bank_name": "string",
    "account_name": "string"
    // or
    "mobile_number": "string",
    "provider": "string"
  }
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Withdrawal request submitted successfully",
  "data": {
    "transaction_id": "string",
    "amount": "number",
    "status": "pending"
  }
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid amount, payment method, or insufficient balance)
- 404: Not Found (Driver not found)

## 5. Verify Payment
**Endpoint:** `GET /api/wallet/verify-payment/{transaction_id}`

**Path Parameters:**
- `transaction_id`: ID of the transaction

**Query Parameters:**
- `email`: Email of the user or driver
- `user_type`: Type of user ("user" or "driver")

**Response:**
```json
{
  "status": "success",
  "data": {
    "transaction_status": "string", // "completed", "failed", "pending"
    "balance": "number" // updated balance if completed
  }
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Invalid transaction ID)
- 404: Not Found


### Notification Management
#### 1. Get Notifications
**Endpoint:** `GET /api/notifications/{userId}`

**Query Parameters:**

* `user_type`: Type of user ("user" or "driver")
* `page`: Page number (optional, default: 1)
* `limit`: Items per page (optional, default: 10)

**Response:**

```json
{
  "status": "success",
  "data": {
    "notifications": [
      {
        "notification_id": "string",
        "type": "string",
        "title": "string",
        "message": "string",
        "datetime": "string",
        "read": "boolean"
      }
    ],
    "pagination": {
      "total": "number",
      "pages": "number",
      "page": "number",
      "limit": "number"
    }
  }
}
```

**Status Codes:**

* 200: OK
* 404: Not Found (User/Driver not found)

### 2. Mark Notification as Read

**Endpoint:** `PUT /api/notifications/{notification_id}/read`

**Path Variable:**
* `notification_id`: ID of the notification

**Request Body:**

```json
{
  "email": "string", // Email of the user or driver
  "user_type": "string" // "user" or "driver"
}
```
**Response:**

```json
{
  "status": "success",
  "message": "Notification marked as read"
}
```

**Status Codes:**

* 200: OK
* 404: Not Found

### 3. Mark All Notifications as Read
**Endpoint:** `PUT /api/notifications/read-all`

**Request Body:**
```jason
{
  "email": "string", // Email of the user or driver
  "user_type": "string" // "user" or "driver"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "All notifications marked as read"
}
```

**Status Codes:**

* 200: OK
* 404: Not Found (User/Driver not found)



---------------------------------------------------------------------------------------------------


## Vehicle Management
### 1. Get Driver Vehicles
**Endpoint:** `GET /api/drivers/{driverId}vehicles`

**Path Variables:**
* `driverId`: Driver ID for identification

Response:

```json
{
  "status": "success",
  "data": {
    "vehicles": [
      {
        "vehicle_id": "string",
        "vehicle_type": "string",
        "model": "string",
        "license_plate_number": "string",
        "year": "string",
        "color": "string",
        "front_view_image_url": "string",
        "back_view_image_url": "string",
        "status": "string", // "pending", "approved", "rejected"
        "is_active": "boolean"
      }
    ]
  }
}
```

**Status Codes:**

- 200: OK
- 404: Not Found (Driver not found)

### 2. Add Vehicle
**Endpoint:** `POST /api/drivers/vehicles`

**Request Body:**

```json
{
  "email": "string", // Email of the driver
  "vehicle_type": "string",
  "model": "string",
  "license_plate_number": "string",
  "year": "string",
  "color": "string",
  "front_view_image": "file",
  "back_view_image": "file"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Vehicle added successfully and pending approval",
  "data": {
    "vehicle_id": "string",
    "status": "pending"
  }
}
```

**Status Codes:**

- 201: Created
- 400: Bad Request (Invalid input)
- 404: Not Found (Driver not found)
- 409: Conflict (License plate already registered)

### 3. Update Vehicle
**Endpoint:** `PUT /api/drivers/vehicles/{vehicle_id}`

**Path Varibale:**

- `vehicle_id`: ID of the vehicle

**Request Body:**

```json
{
  "email": "string", // Email of the driver
  "model": "string", // optional
  "year": "string", // optional
  "color": "string", // optional
  "front_view_image": "file", // optional
  "back_view_image": "file" // optional
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Vehicle updated successfully and pending approval",
  "data": {
    "vehicle_id": "string",
    "status": "pending"
  }
}
```

**Status Codes:**

- 200: OK
- 400: Bad Request (Invalid input)
- 403: Forbidden (Not authorized to update this vehicle)
- 404: Not Found (Vehicle or driver not found)

### 4. Set Active Vehicle
Endpoint: `PUT /api/drivers/vehicles/{vehicle_id}/set-active`

**Path Parameters:**
- `vehicle_id`: ID of the vehicle

**Request Parameters:**

```json
{
  "vehicle": "string" // match vehicle objec
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Vehicle set as active successfully"
}
```

**Status Codes:**
- 200: OK
- 400: Bad Request (Vehicle not approved)
- 403: Forbidden (Not authorized to update this vehicle)
- 404: Not Found (Vehicle or driver not found)

### 5. Delete Vehicle
Endpoint: `DELETE /api/drivers/vehicles/{vehicle_id}`

**Path Parameters:**
- `vehicle_id` : vehicle identifier

Response:
```json
{
  "status": "success",
  "message": "Vehicle deleted successfully"
}
```

**Status Codes:**

- 200: OK
- 403: Forbidden (Not authorized to delete this vehicle or vehicle in use)
- 404: Not Found (Vehicle or driver not found)
