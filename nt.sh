#!/usr/bin/env ruby

require 'fileutils'

class MyNote
    DIR_PATH = "#{`echo $HOME`.chomp}/MyNote".freeze
    CONTENT_PATH = "#{DIR_PATH}/content".freeze
    VALID_ARGV_1 = %w{ l vn ve n e r rename del help }.freeze

    Dir.mkdir(DIR_PATH) unless Dir.exist?(DIR_PATH)
    Dir.mkdir(CONTENT_PATH) unless Dir.exist?(CONTENT_PATH)

    def call
        first = VALID_ARGV_1.include?(ARGV.first) ? ARGV.first : 'help' 
        send(first)
    end

    private

    def help
        note = <<-EOF

        l                 - list the note
        n file_name       - edit a note OR create a note
        e file_name       - edit a note OR create a note
        vn file_name      - edit a note OR create a note by vim
        ve file_name      - edit a note OR create a note by vim
        r file_name       - read a note
        rename old new    - rename a note
        del               - delete a note
        EOF

        puts note
    end

    def files
        FileUtils.cd(CONTENT_PATH) do
            puts `ls -l | grep -v ^d|awk '{print $9}'`
        end
    end

    def edit_file
        print ' > '
        buf = STDIN.gets
        File.open(full_path, 'a') { |f| f.puts buf }
        read_file
    end

    def vim_edit_file
        system "vim #{full_path}"
        read_file
    end

    def read_file(file_full_name: full_path)
        puts "----------------------- #{ARGV[1]} -----------------------\n\n"
        File.open(file_full_name) do |f|
            puts f.readlines
        end
    end

    def rename
        FileUtils.cd(CONTENT_PATH) do
            File.rename(ARGV[1], ARGV[2])
        end
        puts "changed #{ARGV[1]} to - #{ARGV[2]}"
    end

    def del
        FileUtils.rm(full_path)
        puts "deleted #{ARGV[1]} success!"
    end

    def full_path
        "#{CONTENT_PATH}/#{ARGV[1]}"
    end

    def error_handler(str)
        puts str
    end

    alias_method :n, :edit_file
    alias_method :e, :edit_file
    alias_method :vn, :vim_edit_file
    alias_method :ve, :vim_edit_file
    alias_method :l, :files
    alias_method :r, :read_file
end

MyNote.new.call

