<?php

namespace App\Http\Controllers\API\Auth;

use App\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthAPIController extends Controller
{
    public function register(RegisterRequest $request) {
        $request->validated();

        $userData = [
            'fullname' => $request->fullname,
            'email' => $request->email,
            'username' => $request->username,
            'password' => Hash::make($request->password),
        ];

        $user = User::create($userData);
        $token = $user->createToken('kelolabp')->plainTextToken;

        return response([
            'user' => $user,
            'token' => $token
        ], 201);
    }

    public function login(LoginRequest $request)
    {
        $request->validated();

        $credentials = $request->only('username', 'password');

        if (Auth::attempt($credentials)) {
            // Get the authenticated user instance
            $user = Auth::user();

            // Ensure the user instance is not null
            if ($user) {
                $token = $user->createToken('kelolabp')->plainTextToken;

                return response([
                    'user' => $user,
                    'token' => $token
                ], 200);
            }
        }

        return response([
            'message' => 'Invalid credentials'
        ], 422);
    }

    public function logout(Request $request)
    {
        // Revoke the token that was used to authenticate the current request
        $request->user()->currentAccessToken()->delete();

        return response([
            'message' => 'Logged out successfully'
        ], 200);
    }
}