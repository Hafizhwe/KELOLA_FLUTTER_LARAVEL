<?php

namespace App\Http\Controllers\API;

use App\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Requests\SettingRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class SettingsAPIController extends Controller
{
    /**
     * Update the authenticated user's settings.
     *
     * @param SettingRequest $request
     * @return \Illuminate\Http\Response
     */
    public function update(SettingRequest $request)
    {
        Log::info('SettingsAPIController@update called');
        
        $validatedData = $request->validated();
    
        $user = Auth::user();
        if (!$user) {
            Log::error('User not authenticated');
            return response()->json(['message' => 'Unauthenticated'], 401);
        }
    
        Log::info('User authenticated: ', ['id' => $user->id]);
    
        DB::beginTransaction();
        try {
            $user->username = $validatedData['username'];
            $user->email = $validatedData['email'];
    
            if (!empty($validatedData['password'])) {
                $user->password = Hash::make($validatedData['password']);
            }
    
            $user->save();
            Log::info('User updated: ', ['id' => $user->id]);

            // Invalidate old tokens
            $user->tokens()->delete();
            Log::info('Old tokens invalidated: ', ['id' => $user->id]);
            
            // Generate a new token
            $token = $user->createToken('kelolabp')->plainTextToken;
            Log::info('New token generated: ', ['id' => $user->id]);

            DB::commit();

            return response()->json([
                'user' => $user,
                'token' => $token,
                'message' => 'User updated successfully'
            ], 200);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Error updating user: ', ['error' => $e->getMessage()]);
            return response()->json(['message' => 'Failed to update user settings'], 500);
        }
    }
}
