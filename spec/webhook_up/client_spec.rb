# frozen_string_literal: true
require "spec_helper"

describe WebhookUp::Client do
  let(:namespace) { "MyService" }
  let(:secret) { "abc123" }
  let(:url) { "https://my.example.com/webhooks" }

  describe "#challenge" do
    before do
      allow(WebhookUp::Client).to receive(:generate_challenge).and_return("the_challenge")
    end

    it "works" do
      stub = stub_request(:get, "https://my.example.com/webhooks?hub.challenge=the_challenge&hub.mode=subscribe")
        .with(
          headers: {
            "User-Agent" => "MyService-Webhook",
            "X-Hub-Signature" => "sha1=8024cbaf26fddc7b36684c4fed77b802a322bb29",
          }
        )
        .to_return(status: 200, body: "", headers: {})

      subject = described_class.new(url, namespace: namespace, secret: secret)
      payload = {
        foo: "bar",
      }

      response = subject.challenge
      expect(stub).to have_been_requested
      expect(response).to be_a(::WebhookUp::Response)
      expect(response).to be_success
    end

    context "when url already has query params" do
      let(:url) { "https://my.example.com/webhooks?foo=bar" }

      it "works" do
        stub = stub_request(:get, "https://my.example.com/webhooks?foo=bar&hub.challenge=the_challenge&hub.mode=subscribe")
          .with(
            headers: {
              "User-Agent" => "MyService-Webhook",
              "X-Hub-Signature" => "sha1=8024cbaf26fddc7b36684c4fed77b802a322bb29",
            }
          )
          .to_return(status: 200, body: "", headers: {})

        subject = described_class.new(url, namespace: namespace, secret: secret)
        payload = {
          foo: "bar",
        }

        response = subject.challenge
        expect(stub).to have_been_requested
        expect(response).to be_a(::WebhookUp::Response)
        expect(response).to be_success
      end
    end
  end

  describe "#publish" do
    it "works" do
      stub = stub_request(:post, "https://my.example.com/webhooks")
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

      subject = described_class.new(url, namespace: namespace, secret: secret)
      payload = {
        foo: "bar",
      }

      response = subject.publish("my_event", payload: payload)
      expect(stub).to have_been_requested
      expect(response).to be_a(::WebhookUp::Response)
      expect(response).to be_success
    end

    it "handles timeouts", pending: true do
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

      subject = described_class.new(url, namespace: namespace, secret: secret)
      payload = {
        foo: "bar",
      }

      response = subject.publish("my_event", payload: payload)
      expect(stub).to have_been_requested
      expect(response).to be_a(::WebhookUp::Response)
      expect(response).not_to be_success
    end
  end
end
