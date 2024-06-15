<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DataRequest extends FormRequest
{
    public function authorize()
    {
        return true; // Set to true to authorize all requests by default
    }

    public function rules()
    {
        return [
            'type' => 'required|in:income,expense,tagihan',
            'date' => 'required|date',
            'amount' => 'required|numeric',
            'source_bank' => 'required|string|max:255',
            'notes' => 'nullable|string',
        ];
    }
}
