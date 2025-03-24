module Jekyll
  class TagPageGenerator < Generator
    safe true

    def generate(site)
      tags = site.posts.docs.flat_map { |post| post.data['tags'] || [] }.uniq

      tags.each do |tag|
        site.pages << TagPage.new(site, site.source, 'tag', tag)
      end
    end
  end

  class TagPage < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = "#{tag.downcase.gsub(' ', '-')}.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['title'] = "Tag: #{tag}"
      self.data['tag'] = tag
    end
  end
end