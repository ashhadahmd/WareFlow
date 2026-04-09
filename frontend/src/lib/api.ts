import Cookies from 'js-cookie';

const API_URL = typeof window === 'undefined'
  ? process.env.API_URL || 'http://backend:8000'
  : process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

class ApiClient {
  private getHeaders() {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    const token = Cookies.get('token');
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const warehouseId = Cookies.get('warehouseId');
    if (warehouseId) {
      headers['X-Warehouse-Id'] = warehouseId;
    }

    return headers;
  }

  private async handleResponse<T>(response: Response): Promise<T> {
    if (response.status === 401) {
      Cookies.remove('token');
      Cookies.remove('warehouseId');
      if (typeof window !== 'undefined' && !window.location.pathname.includes('/login')) {
         window.location.href = '/login';
      }
      throw new Error('Unauthorized');
    }

    const data = await response.json();
    
    if (!response.ok) {
        throw new Error(data.detail || data.message || 'API Error');
    }
    
    return data as T;
  }

  async get<T>(endpoint: string, params?: Record<string, any>): Promise<T> {
    const url = new URL(`${API_URL}${endpoint}`);
    if (params) {
      Object.keys(params).forEach(key => url.searchParams.append(key, params[key]));
    }
    
    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.getHeaders(),
    });
    
    return this.handleResponse(response);
  }

  async post<T>(endpoint: string, body: any): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify(body),
    });
    
    return this.handleResponse(response);
  }

  async put<T>(endpoint: string, body: any): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'PUT',
      headers: this.getHeaders(),
      body: JSON.stringify(body),
    });
    
    return this.handleResponse(response);
  }
  
  async patch<T>(endpoint: string, body: any): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'PATCH',
      headers: this.getHeaders(),
      body: JSON.stringify(body),
    });
    
    return this.handleResponse(response);
  }

  async delete<T>(endpoint: string): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'DELETE',
      headers: this.getHeaders(),
    });
    
    return this.handleResponse(response);
  }

  // Auth Specific since it relies on formData
  async login(formData: FormData) {
    const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        body: formData, // do not set content type, fetch does it for formdata
        headers: {
            'Accept': 'application/json'
        }
    });

    if (!response.ok) {
        let errMessage = "Login failed";
        try {
            const data = await response.json();
            errMessage = data.detail || errMessage;
        } catch(e) {}
        throw new Error(errMessage);
    }

    return response.json();
  }
}

export const api = new ApiClient();
