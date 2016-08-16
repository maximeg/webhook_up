# frozen_string_literal: true
require "spec_helper"

describe WebhookUp::Response do
  let(:url) { "https://my.example.com/webhooks" }

  describe "#success?" do
    it "is true for status '200 Ok'" do
      subject = described_class.new(url, status: 200)
      expect(subject.success?).to eq(true)
    end

    it "is true for status '201 Created'" do
      subject = described_class.new(url, status: 201)
      expect(subject.success?).to eq(true)
    end

    it "is true for status '202 Accepted'" do
      subject = described_class.new(url, status: 202)
      expect(subject.success?).to eq(true)
    end

    it "is true for status '204 No Content'" do
      subject = described_class.new(url, status: 204)
      expect(subject.success?).to eq(true)
    end

    it "is false for status '300 Multiple Choices'" do
      subject = described_class.new(url, status: 300)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '301 Moved Permanently'" do
      subject = described_class.new(url, status: 301)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '302 Moved Temporarily'" do
      subject = described_class.new(url, status: 302)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '303 See Other'" do
      subject = described_class.new(url, status: 303)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '304 Not Modified'" do
      subject = described_class.new(url, status: 304)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '307 Temporary Redirect'" do
      subject = described_class.new(url, status: 307)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '308 Permanent Redirect'" do
      subject = described_class.new(url, status: 308)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '310 Too many Redirects'" do
      subject = described_class.new(url, status: 310)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '400 Bad Request'" do
      subject = described_class.new(url, status: 400)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '401 Unauthorized'" do
      subject = described_class.new(url, status: 401)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '402 Payment Required'" do
      subject = described_class.new(url, status: 402)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '403 Forbidden'" do
      subject = described_class.new(url, status: 403)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '404 Not Found'" do
      subject = described_class.new(url, status: 404)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '405 Method Not Allowed'" do
      subject = described_class.new(url, status: 405)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '406 Not Acceptable'" do
      subject = described_class.new(url, status: 406)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '408 Request Time-out'" do
      subject = described_class.new(url, status: 408)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '409 Conflict'" do
      subject = described_class.new(url, status: 409)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '410 Gone'" do
      subject = described_class.new(url, status: 410)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '418 I’m a teapot'" do
      subject = described_class.new(url, status: 418)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '422 Unprocessable entity'" do
      subject = described_class.new(url, status: 422)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '429 Too Many Requests'" do
      subject = described_class.new(url, status: 429)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '500 Internal Server Error'" do
      subject = described_class.new(url, status: 500)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '501 Not Implemented'" do
      subject = described_class.new(url, status: 501)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '502 Bad Gateway'" do
      subject = described_class.new(url, status: 502)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '503 Service Unavailable'" do
      subject = described_class.new(url, status: 503)
      expect(subject.success?).to eq(false)
    end

    it "is false for status '504 Gateway Time-out'" do
      subject = described_class.new(url, status: 504)
      expect(subject.success?).to eq(false)
    end



  end
end
