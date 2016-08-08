require 'rails_helper'

describe ThreadsController, type: :controller do
  before :all do
    FactoryGirl.reload
    created_messages = create_list(:message, 20)
    FactoryGirl.reload
    create(:message) # uid 00000000000000000001 のデータを複数投入
  end

  describe 'GET #ajax_list' do
    it "return http success" do
      xhr :get, :ajax_list
      expect(response.status).to eq(200)
    end

    context "リクエスト引数UID" do
      example "設定されていない場合" do
        xhr :get, :ajax_list
        expect(response.body).to eq ""
      end

      example "設定されていて、対象URIのmessageデータが存在しない場合" do
        uid = "00000000000000000021"
        xhr :get, :ajax_list, :uid => uid
        messages = Message.where(:uid => uid)
        expect(response.body).to eq '[]'
      end

      example "設定されていて、対象UIDのmessageデータ(単数)が存在する場合" do
        uid = "00000000000000000002"
        xhr :get, :ajax_list, :uid => uid
        messages = Message.where(:uid => uid)
        expect(response.body).to eq messages.to_json
      end

      example "設定されていて、対象UIDのmessageデータ(複数)が存在する場合" do
        uid = "00000000000000000001"
        xhr :get, :ajax_list, :uid => uid
        messages = Message.where(:uid => uid)
        expect(messages.size).to eq(2)
        expect(response.body).to eq messages.to_json
      end
    end

    context "セッション設定" do
      example "リクエスト引数UIDが設定時、セッションに設定される事" do
        uid = "00000000000000000001"
        xhr :get, :ajax_list, :uid => uid
        expect(session[:uid]).to eq uid
      end
  
      example "リクエスト引数UIDが空時、セッションに空が設定される事" do
        uid = ""
        xhr :get, :ajax_list, :uid => uid
        expect(session[:uid]).to eq ""
      end
    end
  end

  describe 'POST #ajax_post' do
    it "return http success" do
      inputText = "aaaa"
      xhr :post, :ajax_post, :inputText => inputText
      expect(response.status).to eq(200)
    end

    context "送信メッセージ" do
      example "空の場合" do
        uid = "00000000000000000099"
        session = { 'uid' => uid }
        add_session(session)
        inputText = ""
        xhr :post, :ajax_post, :inputText => inputText
        expect(response.body).to be_empty
      end

      example "未設定の場合" do
        uid = "00000000000000000099"
        session = { 'uid' => uid }
        add_session(session)        
        xhr :post, :ajax_post
        expect(response.body).to be_empty
      end
    end
      
    context "セッションUID" do
      example "空の場合" do
        uid = ""
        session = { 'uid' => uid }
        add_session(session)        
        inputText = "aaa"
        xhr :post, :ajax_post, :inputText => inputText
        expect(response.body).to be_empty
      end
      
      example "未設定の場合" do
        inputText = "aaa"
        xhr :post, :ajax_post, :inputText => inputText
        expect(response.body).to be_empty
      end
    end
    
    context "人工知能ボットAPIコール異常系" do
      example "statusにerror設定時" do
        result = Hash.new
        result["status"] = "error"
        allow_any_instance_of(ThreadsController).to receive(:get_ai_response).and_return(result)
        expect_any_instance_of(ThreadsController).to receive(:get_ai_response).once
        
        uid = "00000000000000000099"
        session = { 'uid' => uid }
        session[:uid] = uid
        add_session(session)        
        inputText = "aaa"
        xhr :post, :ajax_post, :inputText => inputText
        
        expect(response.body).to include(I18n.t('errors.messages.bot_api'))
        expect(response.status).to eq 422
      end    
      
      example "status 未設定時" do
        result = Hash.new
        allow_any_instance_of(ThreadsController).to receive(:get_ai_response).and_return(result)
        expect_any_instance_of(ThreadsController).to receive(:get_ai_response).once
        
        uid = "00000000000000000099"
        session = { 'uid' => uid }
        session[:uid] = uid
        add_session(session)        
        inputText = "aaa"
        xhr :post, :ajax_post, :inputText => inputText
        
        expect(response.body).to include(I18n.t('errors.messages.bot_api'))
        expect(response.status).to eq 422
      end
    end

    context "データ保存" do
      example "正常系" do
        uid = "00000000000000000099"
        session = { 'uid' => uid }
        session[:uid] = uid
        add_session(session)        
        inputText = "aaa"

        beforeCount = Message.where(:uid => uid).count
        
        xhr :post, :ajax_post, :inputText => inputText

        message = Message.where(:uid => uid).first
        afterCount = Message.where(:uid => uid).count
        expect(beforeCount).to eq 0
        expect(afterCount).to eq 1

        expect(message[:uid]).to eq uid
        expect(message[:input_text]).to eq "aaa"
        expect(message[:res_status]).to eq "success"
        expect(message[:res_text]).not_to eq ""
        expect(message[:created_at]).not_to be_nil
        expect(message[:updated_at]).not_to be_nil
      end
      
      example "異常系" do
        uid = "00000000000000000099"
        session = { 'uid' => uid }
        session[:uid] = uid
        add_session(session)        
        inputText = "1" * 201

        beforeCount = Message.where(:uid => uid).count
        
        xhr :post, :ajax_post, :inputText => inputText

        message = Message.where(:uid => uid).first
        afterCount = Message.where(:uid => uid).count
        expect(beforeCount).to eq 0
        expect(afterCount).to eq 0
        expect(response.body).not_to be_empty
        expect(response.status).to eq 422
      end
    end
  end
  
  describe 'get_ai_response' do
    example "正常系" do
      threadsController = ThreadsController.new
      result = threadsController.send(:get_ai_response, Constants::BOT_API_URL, Constants::BOT_API_KEY, "aaaa")
      expect(result["status"]).to eq "success"
      expect(result["result"]).not_to eq ""
    end

    context "異常系" do
      example "APIキー不正" do
        threadsController = ThreadsController.new
        result = threadsController.send(:get_ai_response, Constants::BOT_API_URL, "testerrorhogehoge", "aaaa")
        expect(result["status"]).to eq "Token invalid."
        expect(result["result"]).to eq ""
      end

      example "URL不正" do
        threadsController = ThreadsController.new
        result = threadsController.send(:get_ai_response, "http://www.yahoo.co.jp", Constants::BOT_API_KEY, "aaaa")
        expect(result["status"]).to be_nil
      end
      
      example "空メッセージ" do
        threadsController = ThreadsController.new
        result = threadsController.send(:get_ai_response, Constants::BOT_API_URL, Constants::BOT_API_KEY, "")
        expect(result["status"]).to eq "message(or name) blank."
      end
    end
    
  end

end