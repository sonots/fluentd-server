require 'fluentd_server/config'
require 'fluentd_server/model'

if FluentdServer::Config.test_database_url.start_with?('file')
  describe Post do
    it { expect(Post.superclass).to eql(Object) }

    context '#new' do
      let(:subject) { Post.new(name: 'aaaa', body: 'aaaa') }
      its(:name) { should == 'aaaa' }
      its(:body) { should == 'aaaa' }
    end

    context '#save' do
      let(:post) { Post.new(name: 'aaaa', body: 'aaaa') }
      before { post.save }
      it { expect(File.exist?(post.filename)).to be_true }
      it { expect(File.read(post.filename)).to eql('aaaa') }
      it { expect(File.mtime(post.filename)).to eql(post.cached_at) }
    end

    context '.create' do
      let(:post) { Post.create(name: 'aaaa', body: 'aaaa') }
      it { expect(File.exist?(post.filename)).to be_true }
      it { expect(post.created_at).not_to be_nil }
      it { expect(post.updated_at).not_to be_nil }
    end

    context '#update' do
    end

    context '#destroy' do
    end

    context '#to_h' do
      let(:post) { Post.create(name: 'aaaa', body: 'aaaa') }
      let(:subject) { post.to_h }
      it {
        expect(subject[:name]).to eql('aaaa')
        expect(subject[:body]).to eql('aaaa')
        expect(subject[:created_at]).not_to be_nil
        expect(subject[:updated_at]).not_to be_nil
      }
    end

    context '#to_json' do
      let(:post) { Post.create(name: 'aaaa', body: 'aaaa') }
      let(:subject) { post.to_json }
      it {
        hash = JSON.parse(subject)
        expect(hash['name']).to eql('aaaa')
        expect(hash['body']).to eql('aaaa')
        expect(hash['created_at']).not_to be_nil
        expect(hash['updated_at']).not_to be_nil
      }
    end

    context '#body' do
      context 'read from cache' do
        let(:post) { Post.new(name: 'aaaa', body: 'aaaa') }
        before { post.save; @cached_at = post.cached_at }
        it {
          expect(post.body).to eql('aaaa')
          expect(post.cached_at).to eql(@cached_at)
        }
      end

      context 'read to cache' do
        let(:post) { Post.new(name: 'aaaa', body: 'aaaa') }
        before { post.save; @cached_at = post.cached_at }
        before { sleep 1; File.write(post.filename, 'bbbb') }
        it {
          expect(post.body).to eql('bbbb')
          expect(post.cached_at).to be > @cached_at
        }
      end
    end

    context '.order("name ASC")' do
      before { @post = Post.create(name: 'aaaa', body: 'aaaa') }
      let(:posts) { Post.order("name ASC") }
      it { expect(posts.first.to_h).to eql(@post.to_h) }
    end

    context '.count' do
    end

    context '.first' do
    end

    context '.find_by(name: name)' do
      before { @post = Post.create(name: 'aaaa', body: 'aaaa') }
      let(:post) { Post.find_by(name: 'aaaa') }
      it { expect(post.to_h).to eql(@post.to_h) }
    end

    context '.delete_all' do
      before { @post = Post.create(name: 'aaaa', body: 'aaaa') }
      before { Post.delete_all }
      it { expect{ Post.find_by(name: 'aaaa') }.to raise_error(Errno::ENOENT) }
    end
  end
end
