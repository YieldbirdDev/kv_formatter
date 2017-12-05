# frozen_string_literal: true

RSpec.describe Logger::KeyValueFormatter do
  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  let(:now) { Time.utc(2016, 12, 15, 18, 30, 45) }

  let(:severity) { "INFO" }
  let(:progname) { double(:progname) }

  before { Timecop.freeze(now) }
  after  { Timecop.return }

  subject { described_class.new }

  describe "#call" do
    let(:formatted_output) { subject.call(severity, now, progname, input) }

    shared_examples "key value formatter" do
      it "outputs properly formatted input data" do
        expected_output.each do |output|
          expect(formatted_output).to include(output)
        end
      end
    end

    context "when custom proc was passed" do
      subject { described_class.new { |*| { custom: :data } } }

      it_behaves_like "key value formatter" do
        let(:input) { {} }

        let(:expected_output) { ["custom=data"] }
      end
    end

    context "when raw string on input" do
      let(:input) { "foo bar test" }

      let(:expected_output) { "#{input}\n" }

      it "returns string without formatting" do
        expect(formatted_output).to eq expected_output
      end
    end

    context "when hash on input" do
      it_behaves_like "key value formatter" do
        let(:input) { {} }

        let(:expected_output) { ['source="APP"', 'at="INFO"', 'timestamp="2016-12-15T18:30:45Z"'] }
      end

      context "when contains source parameter" do
        it_behaves_like "key value formatter" do
          let(:input) { { source: "foo", bar: "baz" } }

          let(:expected_output) { ['source="foo"'] }
        end
      end

      context "when unnested" do
        it_behaves_like "key value formatter" do
          let(:input) { { foo: "bar", baz: "test" } }

          let(:expected_output) { ['foo="bar"', 'baz="test"'] }
        end
      end

      context "when singly nested" do
        it_behaves_like "key value formatter" do
          let(:input) { { foo: { bar: "baz" } } }

          let(:expected_output) { ['foo-bar="baz"'] }
        end
      end

      context "when repeatedly nested" do
        it_behaves_like "key value formatter" do
          let(:input) { { foo: { bar: { baz: "test" } } } }

          let(:expected_output) { ['foo-bar={"baz":"test"}'] }
        end
      end
    end

    context "when unsupported object type on input" do
      it_behaves_like "key value formatter" do
        let(:input) { double :unsupported_object, inspect: "foo bar test" }

        let(:expected_output) { ["foo bar test"] }
      end
    end

    describe "hash value formatting" do
      context "string" do
        it_behaves_like "key value formatter" do
          let(:input) { { foo: "bar" } }

          let(:expected_output) { ['foo="bar"'] }
        end
      end

      context "float" do
        it_behaves_like "key value formatter" do
          let(:input) { { foo: 57.54321 } }

          let(:expected_output) { ["foo=57.543"] }
        end
      end

      context "time" do
        it_behaves_like "key value formatter" do
          let(:input) { { foo: now } }

          let(:expected_output) { ['foo="2016-12-15T18:30:45Z"'] }
        end
      end

      context "nil" do
        it_behaves_like "key value formatter" do
          let(:input) { { foo: nil } }

          let(:expected_output) { ["foo=nil"] }
        end
      end
    end

    describe "complex entries" do
      it_behaves_like "key value formatter" do
        let(:base_input) do
          {
            a: "foobar",
            b: 57,
            c: 57.54321,
            d: nil,
            e: now
          }
        end

        let(:input) do
          base_input.merge(
            f: base_input.merge(
              g: base_input
            )
          )
        end

        let(:expected_output) do
          [
            'source="APP" at="INFO" timestamp="2016-12-15T18:30:45Z" ' \
            'a="foobar" b=57 c=57.543 d=nil e="2016-12-15T18:30:45Z" ' \
            'f-a="foobar" f-b=57 f-c=57.543 f-d=nil f-e="2016-12-15T18:30:45Z" ' \
            'f-g={"a":"foobar","b":57,"c":57.54321,"d":null,"e":"2016-12-15 18:30:45 UTC"}'
          ]
        end
      end
    end
  end
end
