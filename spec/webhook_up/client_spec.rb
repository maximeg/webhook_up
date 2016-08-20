# frozen_string_literal: true
require "spec_helper"

describe WebhookUp::Client do
  let(:namespace) { "MyService" }
  let(:secret) { "abc123" }
  let(:url) { "https://my.example.com/webhooks" }

  subject { described_class.new(url, namespace: namespace, secret: secret) }

  describe "#challenge" do
    before do
      allow(WebhookUp::Client).to receive(:generate_challenge).and_return("the_challenge")
    end

    context "when the callback url responds with the challenge" do
      before do
        stub_request(:get, "https://my.example.com/webhooks?hub.challenge=the_challenge&hub.mode=subscribe")
          .with(
            headers: {
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=8024cbaf26fddc7b36684c4fed77b802a322bb29",
            }
          )
          .to_return(status: 200, body: "the_challenge", headers: {})
      end

      it "returns a successful result" do
        result = subject.challenge
        expect(result).to be_a(::WebhookUp::Result)
        expect(result).to be_success
      end
    end

    context "when the callback url already has query params" do
      let(:url) { "https://my.example.com/webhooks?foo=bar" }

      it "calls the correct url" do
        stub = stub_request(:get, "https://my.example.com/webhooks?foo=bar&hub.challenge=the_challenge&hub.mode=subscribe")
          .with(
            headers: {
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=8024cbaf26fddc7b36684c4fed77b802a322bb29",
            }
          )
          .to_return(status: 200, body: "the_challenge", headers: {})

        result = subject.challenge
        expect(stub).to have_been_requested
      end
    end

    context "when the callback url does not respond with the challenge" do
      before do
        stub_request(:get, "https://my.example.com/webhooks?hub.challenge=the_challenge&hub.mode=subscribe")
          .with(
            headers: {
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=8024cbaf26fddc7b36684c4fed77b802a322bb29",
            }
          )
          .to_return(status: 200, body: "not_the_challenge", headers: {})
      end

      it "returns a non successful result" do
        result = subject.challenge
        expect(result).to be_a(::WebhookUp::Result)
        expect(result).not_to be_success
      end
    end

    context "when the callback url does not respond a 2xx status" do
      before do
        stub_request(:get, "https://my.example.com/webhooks?hub.challenge=the_challenge&hub.mode=subscribe")
          .with(
            headers: {
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=8024cbaf26fddc7b36684c4fed77b802a322bb29",
            }
          )
          .to_return(status: 404, body: "the_challenge", headers: {})
      end

      it "returns a non successful result" do
        result = subject.challenge
        expect(result).to be_a(::WebhookUp::Result)
        expect(result).not_to be_success
      end
    end

    context "when the callback url does timeout", pending: true do
      before do
        stub_request(:get, "https://my.example.com/webhooks?hub.challenge=the_challenge&hub.mode=subscribe")
          .with(
            headers: {
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=8024cbaf26fddc7b36684c4fed77b802a322bb29",
            }
          )
          .to_timeout
      end

      it "returns a non successful result" do
        result = subject.challenge
        expect(result).to be_a(::WebhookUp::Result)
        expect(result).not_to be_success
      end
    end
  end

  describe "#publish" do
    context "when the callback url responds a 2xx status" do
      before do
        stub_request(:post, "https://my.example.com/webhooks")
          .with(
            body: "{\"foo\":\"bar\"}",
            headers: {
              "Content-Type" => "application/json",
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=177880ce9b83e0cf51d0b34c24b04c2c59160426",
              "X-Myservice-Delivery" => "a5e744d0164540d33b1d7ea616c28f2fa97e754a",
              "X-Myservice-Event" => "my_event",
            }
          )
          .to_return(status: 200, body: "", headers: {})
      end

      it "returns a successful result" do
       result = subject.publish("my_event", payload: {
          foo: "bar",
        })
        expect(result).to be_a(::WebhookUp::Result)
        expect(result).to be_success
      end
    end

    context "when the callback url responds a 404 status" do
      before do
        stub_request(:post, "https://my.example.com/webhooks")
          .with(
            body: "{\"foo\":\"bar\"}",
            headers: {
              "Content-Type" => "application/json",
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=177880ce9b83e0cf51d0b34c24b04c2c59160426",
              "X-Myservice-Delivery" => "a5e744d0164540d33b1d7ea616c28f2fa97e754a",
              "X-Myservice-Event" => "my_event",
            }
          )
          .to_return(status: 404, body: "", headers: {})
      end

      it "returns a non successful result" do
       result = subject.publish("my_event", payload: {
          foo: "bar",
        })
        expect(result).to be_a(::WebhookUp::Result)
        expect(result).not_to be_success
      end
    end

    context "when the callback url does timeout", pending: true do
      before do
        stub_request(:post, "https://my.example.com/webhooks")
          .with(
            body: "{\"foo\":\"bar\"}",
            headers: {
              "Content-Type" => "application/json",
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=177880ce9b83e0cf51d0b34c24b04c2c59160426",
              "X-Myservice-Delivery" => "a5e744d0164540d33b1d7ea616c28f2fa97e754a",
              "X-Myservice-Event" => "my_event",
            }
          )
          .to_timeout
      end

      it "returns a non successful result" do
       result = subject.publish("my_event", payload: {
          foo: "bar",
        })
        expect(result).to be_a(::WebhookUp::Result)
        expect(result).not_to be_success
      end
    end
  end
end
