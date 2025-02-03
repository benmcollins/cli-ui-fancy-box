# typed: true
# frozen_string_literal: true

require 'cli/ui'

include CLI::UI

module FancyBox
  extend Frame::FrameStyle
  VERTICAL     = '║'
  HORIZONTAL   = '═'

  TOP_LEFT     = '╔'
  DIVIDER      = '╠'
  BOTTOM_LEFT  = '╚'

  TOP_RIGHT    = '╗'
  DIVIDER_END  = '╣'
  BOTTOM_RIGHT = '╝'

  TEXT_PRE     = '❱'
  TEXT_POST    = '❰'

  @@box_width = Terminal.width

  @@color = Color::WHITE.code

  class << self
    extend T::Sig

    sig { override.params(width: String).returns(Integer) }
    def width=(width)
      @@box_width = width
    end

    sig { override.returns(Symbol) }
    def style_name
      :fancy_box
    end

    sig { override.returns(String) }
    def prefix
      VERTICAL
    end

    sig { override.returns(String) }
    def lineterm
      print_at_x(@@box_width - 1, @@color + VERTICAL)
    end

    #   ╔══ Open ═══════════════════════════════════════════════════╗
    #
    sig { override.params(text: String, color: Color).returns(String) }
    def start(text, color:)
      edge(text, color: color, first: TOP_LEFT, last: TOP_RIGHT)
    end

    #   ╠══ Divider ════════════════════════════════════════════════╣
    #
    sig { override.params(text: String, color: Color).returns(String) }
    def divider(text, color:)
      edge(text, color: color, first: DIVIDER, last: DIVIDER_END)
    end

    #   ╚══ Close ══════════════════════════════════════════════════╝
    #
    sig { override.params(text: String, color: Color, right_text: T.nilable(String)).returns(String) }
    def close(text, color:, right_text: nil)
      edge(text, color: color, right_text: right_text, first: BOTTOM_LEFT, last: BOTTOM_RIGHT)
    end

    private

    sig do
      params(text: String, color: Color, first: String, right_text: T.nilable(String)).returns(String)
    end
    def edge(text, color:, first:, last:, right_text: nil)
      # We save the current color so #lineterm can use it
      @@color = color.code

      preamble = +''

      preamble << color.code if CLI::UI.enable_color?
      preamble << first << (HORIZONTAL * 2)

      unless text.empty?
        preamble << TEXT_PRE << ' '
        preamble << CLI::UI.resolve_text("{{#{color.name}:#{text}}}")
        preamble << color.code if CLI::UI.enable_color?
        preamble << ' ' << TEXT_POST
      end

      termwidth = @@box_width

      suffix = +''

      if right_text
        suffix << TEXT_PRE << ' ' << right_text << ' ' << TEXT_POST
      end

      preamble_width = ANSI.printing_width(preamble)
      preamble_start = Frame.prefix_width
      # If prefix_width is non-zero, we need to subtract the width of
      # the final space, since we're going to write over it.
      preamble_start -= 1 if preamble_start.nonzero?
      preamble_end = preamble_start + preamble_width

      suffix_width = ANSI.printing_width(suffix)
      suffix_end   = termwidth - 2
      suffix_start = suffix_end - suffix_width

      if preamble_end > suffix_start
        suffix = ''
        # if preamble_end > termwidth
        # we *could* truncate it, but let's just let it overflow to the
        # next line and call it poor usage of this API.
      end

      o = +''

      unless CLI::UI.enable_cursor?
        linewidth = [0, termwidth - (preamble_end + suffix_width + 1)].max

        o << color.code if CLI::UI.enable_color?
        o << preamble
        o << color.code if CLI::UI.enable_color?
        o << (HORIZONTAL * linewidth)
        o << color.code if CLI::UI.enable_color?
        o << suffix
        o << Color::RESET.code if CLI::UI.enable_color?
        o << "\n"
        return o
      end

      # Jumping around the line can cause some unwanted flashes
      o << ANSI.hide_cursor

      # reset to column 1 so that things like ^C don't ruin formatting
      o << "\r"

      # This code will print out a full line with the given preamble and
      # suffix, as exemplified below.
      #
      # preamble_start                         suffix_start
      # |                 preamble_end         |            suffix_end
      # |                 |                    |            | termwidth
      # |                 |                    |            | |
      # V                 V                    V            V V
      # |-- Preamble text --------------------- suffix text -|
      o << color.code if CLI::UI.enable_color?
      o << print_at_x(preamble_start, HORIZONTAL * (termwidth - preamble_start)) # draw a full line
      o << print_at_x(termwidth - 1, last)
      o << print_at_x(preamble_start, preamble)
      o << color.code if CLI::UI.enable_color?
      o << print_at_x(suffix_start, suffix)
      o << Color::RESET.code if CLI::UI.enable_color?
      o << ANSI.show_cursor
      o << "\n"

      o
    end
  end
end
