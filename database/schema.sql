-- Hand Embroidery & Mehndi Artist Database Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
CREATE TYPE request_status AS ENUM ('new', 'in_progress', 'completed', 'cancelled');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');

-- Products table
CREATE TABLE products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category VARCHAR(100) NOT NULL,
  images TEXT[] DEFAULT '{}',
  featured BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  stock_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  customer_name VARCHAR(255) NOT NULL,
  customer_email VARCHAR(255) NOT NULL,
  customer_phone VARCHAR(50),
  shipping_address JSONB NOT NULL,
  items JSONB NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  shipping_cost DECIMAL(10,2) DEFAULT 0,
  discount DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  status order_status DEFAULT 'pending',
  payment_method VARCHAR(50),
  payment_status VARCHAR(50) DEFAULT 'pending',
  coupon_code VARCHAR(50),
  special_instructions TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Custom Design Requests table
CREATE TABLE custom_requests (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  occasion VARCHAR(100),
  budget VARCHAR(50),
  timeline VARCHAR(50),
  color_preferences TEXT,
  style_preferences TEXT,
  description TEXT NOT NULL,
  reference_images TEXT[] DEFAULT '{}',
  status request_status DEFAULT 'new',
  admin_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mehndi Bookings table
CREATE TABLE mehndi_bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  service_type VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  duration VARCHAR(50),
  location VARCHAR(255),
  guest_count INTEGER,
  special_requests TEXT,
  status booking_status DEFAULT 'pending',
  total_cost DECIMAL(10,2),
  admin_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Contact Messages table
CREATE TABLE messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT false,
  replied BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Gallery Images table
CREATE TABLE gallery (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  category VARCHAR(100) NOT NULL,
  tags TEXT[] DEFAULT '{}',
  featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Newsletter Subscriptions table
CREATE TABLE newsletter_subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin Users table
CREATE TABLE admin_users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  role VARCHAR(50) DEFAULT 'admin',
  active BOOLEAN DEFAULT true,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Website Settings table
CREATE TABLE website_settings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value JSONB,
  description TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_featured ON products(featured);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_custom_requests_status ON custom_requests(status);
CREATE INDEX idx_mehndi_bookings_date ON mehndi_bookings(date);
CREATE INDEX idx_mehndi_bookings_status ON mehndi_bookings(status);
CREATE INDEX idx_messages_read ON messages(read);
CREATE INDEX idx_gallery_category ON gallery(category);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_custom_requests_updated_at BEFORE UPDATE ON custom_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_mehndi_bookings_updated_at BEFORE UPDATE ON mehndi_bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_website_settings_updated_at BEFORE UPDATE ON website_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO products (name, description, price, category, images, featured, stock_quantity) VALUES
('Floral Embroidered Earrings', 'Beautiful handcrafted earrings with intricate floral embroidery', 1299.00, 'earrings', ARRAY['https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400'], true, 10),
('Traditional Hoop Design', 'Classic embroidery hoop with traditional patterns', 899.00, 'hoops', ARRAY['https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?w=400'], true, 15),
('Botanical Wall Art', 'Custom embroidered botanical wall art piece', 2499.00, 'decor', ARRAY['https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400'], true, 5),
('Vintage Cushion Cover', 'Embroidered cushion cover with vintage motifs', 899.00, 'decor', ARRAY['https://images.unsplash.com/photo-1574180566232-aaad1b5b8450?w=400'], false, 20),
('Bridal Jewelry Set', 'Complete bridal set with embroidered elements', 3999.00, 'jewelry', ARRAY['https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400'], true, 3),
('Modern Table Runner', 'Contemporary embroidered table runner', 1599.00, 'decor', ARRAY['https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400'], false, 8);

-- Insert sample gallery images
INSERT INTO gallery (title, description, image_url, category, featured) VALUES
('Bridal Mehndi Design', 'Intricate bridal mehndi pattern for wedding ceremony', 'https://images.unsplash.com/photo-1583391733956-6c78276477e3?w=400', 'mehndi', true),
('Arabic Style Mehndi', 'Beautiful Arabic mehndi design for special occasions', 'https://images.unsplash.com/photo-1582650625119-3a31f8fa2699?w=400', 'mehndi', true),
('Floral Embroidery Work', 'Detailed floral embroidery on fabric', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400', 'embroidery', true),
('Traditional Hoop Art', 'Classic embroidery hoop with traditional motifs', 'https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?w=400', 'embroidery', false),
('Minimalist Mehndi', 'Simple and elegant mehndi design', 'https://images.unsplash.com/photo-1595348016382-4e6b0e33c7fd?w=400', 'mehndi', false),
('Custom Wall Art', 'Personalized embroidered wall art piece', 'https://images.unsplash.com/photo-1574180566232-aaad1b5b8450?w=400', 'embroidery', true);

-- Insert website settings
INSERT INTO website_settings (setting_key, setting_value, description) VALUES
('site_title', '"Hand Embroidery by Sana"', 'Website title'),
('contact_email', '"hello@embroideryart.com"', 'Contact email address'),
('contact_phone', '"+91 98765 43210"', 'Contact phone number'),
('free_shipping_threshold', '699', 'Free shipping minimum order amount'),
('shipping_rate', '99', 'Standard shipping rate'),
('social_instagram', '"https://instagram.com/embroidery_art"', 'Instagram profile URL'),
('social_facebook', '"https://facebook.com/embroideryart"', 'Facebook page URL'),
('social_whatsapp', '"+91 98765 43210"', 'WhatsApp contact number'),
('business_address', '"Mumbai, Maharashtra, India"', 'Business address'),
('working_hours', '"10 AM - 8 PM, Monday to Saturday"', 'Business working hours');

-- Enable Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE mehndi_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE newsletter_subscriptions ENABLE ROW LEVEL SECURITY;

-- Create policies for public access to products and gallery
CREATE POLICY "Public can view active products" ON products FOR SELECT USING (active = true);
CREATE POLICY "Public can view gallery" ON gallery FOR SELECT USING (true);

-- Create policies for authenticated operations
CREATE POLICY "Anyone can create orders" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can create custom requests" ON custom_requests FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can create bookings" ON mehndi_bookings FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can create messages" ON messages FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can subscribe to newsletter" ON newsletter_subscriptions FOR INSERT WITH CHECK (true);