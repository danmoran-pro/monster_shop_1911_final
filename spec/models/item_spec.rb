require 'rails_helper'

describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price }
    it { should validate_presence_of :inventory }
    it { should validate_inclusion_of(:active?).in_array([true,false]) }
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :reviews}
    it {should have_many :item_orders}
    it {should have_many(:orders).through(:item_orders)}
  end

  describe "instance methods" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
      @tire = @bike_shop.items.create(name: "Tire", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12, purchased: 20)
      @high_roller_ball = @bike_shop.items.create(name: "High Roller Ball", description: "Stays on surface", price: 100, image: "https://www.rei.com/media/3cda9ce5-420c-47d2-8095-bdc6ed84923c?size=784x588", inventory: 12, purchased: 19)
      @gnawt_a_rock = @bike_shop.items.create(name: "Gnawt-A-Rock", description: "Holds treats", price: 100, image: "https://www.rei.com/media/252b0d74-f3cc-4b9d-8a7f-596440dfcc6c?size=784x588", inventory: 12, purchased: 18)
      @gnawt_a_stick = @bike_shop.items.create(name: "Gnawt-A-Stick", description: "Stays upright", price: 100, image: "https://www.rei.com/media/40d8402b-8415-4cab-a9fd-eba14298527d?size=784x588", inventory: 12, purchased: 16)
      @hydro_plane = @bike_shop.items.create(name: "Hydro Plane", description: "Maintains shape", price: 100, image: "https://www.rei.com/media/be369a77-4a9b-426a-b67a-12649856fb9c?size=784x588", inventory: 12, purchased: 14)

      @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5)
      @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4)
      @review_3 = @chain.reviews.create(title: "Meh place", content: "They have meh bike stuff and I probably won't come back", rating: 1)
      @review_4 = @chain.reviews.create(title: "Not too impressed", content: "v basic bike shop", rating: 2)
      @review_5 = @chain.reviews.create(title: "Okay place :/", content: "Brian's cool and all but just an okay selection of items", rating: 3)
    end

    it "calculate average review" do
      expect(@chain.average_review).to eq(3.0)
    end

    it "sorts reviews" do
      top_three = @chain.sorted_reviews(3,:desc)
      bottom_three = @chain.sorted_reviews(3,:asc)

      expect(top_three).to eq([@review_1,@review_2,@review_5])
      expect(bottom_three).to eq([@review_3,@review_4,@review_5])
    end

    it 'no orders' do
      expect(@chain.no_orders?).to eq(true)
      
      user = create(:regular_user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      
      order = user.orders.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
      order.item_orders.create(item: @chain, price: @chain.price, quantity: 2)
      expect(@chain.no_orders?).to eq(false)
    end
    
    it ".most_popular" do
      expect(Item.most_popular.first).to eq(@tire)
    end
    
    it ".least_popular" do
      expect(Item.least_popular.first).to eq(@chain)
    end
    
    it "#item_order" do
      user = create(:regular_user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      order = user.orders.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
      item_order = order.item_orders.create(item: @chain, price: @chain.price, quantity: 2)
      
      expect(@chain.item_order(order.id)).to eq(item_order)
    end
    
    it "#activate" do
      @chain.activate
      expect(@chain.active?).to eq(true)
    end
    
    it "#deactivate" do
      @chain.deactivate
      expect(@chain.active?).to eq(false)
    end
  end
end
