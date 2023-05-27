module Dino
  module Display
    class Canvas
      include Dino::Fonts

      attr_reader :columns, :rows, :framebuffer
    
      def initialize(columns, rows)
        raise ArgumentError, "bitmap height must be divisible by 8" unless (rows % 8 == 0)

        @columns     = columns
        @rows        = rows

        # Use a byte array for the framebuffer. Each byte is 8 pixels arranged vertically.
        # Each slice @columns long represents an area @columns wide * 8 pixels tall.
        @bytes       = @columns * (@rows / 8)
        @framebuffer = Array.new(@bytes) { 0x00 }
      end

      def fill
        @framebuffer.fill(0xFF)
      end

      def clear
        @framebuffer.fill(0x00)
      end

      def get_pixel(x, y)
        byte = ((y / 8) * @columns) + x
        bit  = y % 8
        (@framebuffer[byte] >> bit) & 0b00000001
      end

      def set_pixel(x, y)
        byte = ((y / 8) * @columns) + x
        bit  = y % 8
        @framebuffer[byte] |= (0b1 << bit)
      end

      def clear_pixel(x, y)
        byte = ((y / 8) * @columns) + x
        bit  = y % 8
        @framebuffer[byte] &= ~(0b1 << bit)
      end

      def pixel(x, y, state=0)
        (state == 0) ? clear_pixel(x, y) : set_pixel(x, y)
      end

      # Draw a line based on Bresenham's line algorithm.
      def line(x1, y1, x2, y2, color=1)
        # Deltas in each axis.
        dy = y2 - y1
        dx = x2 - x1

        # Catch vertical lines to avoid division by 0.
        if (dx == 0)
          # Ensure y1 < y2.
          y1, y2 = y2, y1 if (y2 < y1)
          (y1..y2).each do |y|
            pixel(x1, y, color)
          end
          return
        end

        gradient = dy.to_f / dx

        # Gradient magnitude <= 45 degrees: find y for each x.
        if (gradient >= -1) && (gradient <= 1)
          # Ensure x1 < x2.
          x1, y1, x2, y2 = x2, y2, x1, y1 if (x2 < x1)

          # When x increments, add gradient to y.
          y = y1
          y_step = gradient
          (x1..x2).each do |x|
            pixel(x, y.round, color)
            y = y + y_step
          end

        # Gradient magnitude > 45 degrees: find x for each y.
        else
          # Ensure y1 < y2.
          x1, y1, x2, y2 = x2, y2, x1, y1 if (y2 < y1)

          # When y increments, add inverse of gradient to x.
          x = x1
          x_step = 1 / gradient
          (y1..y2).each do |y|
            pixel(x.round, y, color)
            x = x + x_step
          end
        end
      end

      # Rectangles and squares as a combination of lines.
      def rectangle(x, y, width, height, color=1)
        line(x,       y,        x+width, y,        color)
        line(x+width, y,        x+width, y+height, color)
        line(x+width, y+height, x,       y+height, color)
        line(x,       y+height, x,       y,        color)
      end

      # Draw a vertical line for every x value to get a filled rectangle.
      def filled_rectangle(x, y_start, width, height, color=1)
        y_end = y_start + height
        y_start, y_end = y_end, y_start if (y_end < y_start)
        (y_start..y_end).each do |y|
          line(x, y, x+width, y, color)
        end
      end

      # Open ended path
      def path(points=[], color=1)
        return unless points
        start = points[0]
        (1..points.length-1).each do |i|
          finish = points[i]
          line(start[0], start[1], finish[0], finish[1])
          start = finish
        end
      end

      # Close paths by repeating the start value at the end.
      def polygon(points=[], color=1)
        points << points[0]
        path(points)
      end

      # Filled polygon using horizontal ray casting + stroked polygon.
      def filled_polygon(points=[], color=1)
        # Get all the X and Y coordinates from the points as floats.
        coords_x = points.map { |point| point.first.to_f }
        coords_y = points.map { |point| point.last.to_f  }

        # Get Y bounds of the polygon to limit rows.
        y_min = coords_y.min.to_i
        y_max = coords_y.max.to_i

        # Cast horizontal ray on each row, storing nodes where it intersects polygon edges.
        (y_min..y_max).each do |y|
          nodes = []
          i = 0
          j = points.count - 1

          while (i < points.count) do
            if (coords_y[i] < y && coords_y[j] >= y || coords_y[j] < y && coords_y[i] >= y)
              nodes << (coords_x[i] + (y - coords_y[i]) / (coords_y[j] - coords_y[i]) *(coords_x[j] - coords_x[i])).round
            end
            j  = i
            i += 1
          end
          nodes = nodes.sort

          # Take pairs of nodes and fill between them. This automatically ignores the spaces
          # between even then odd nodes, which are outside the polygon.
          nodes.each_slice(2) do |pair|
            next if pair.length < 2
            line(pair.first, y,  pair.last, y, color)
          end
        end

        # Stroke the polygon anyway. Floating point math misses thin areas.
        polygon(points, color)
      end
      
      # Triangle with 3 points as 6 flat args.
      def triangle(x1, y1, x2, y2, x3, y3, color=1)
        polygon([[x1,y1], [x2,y2], [x3,y3]], color)
      end

      # Filled triangle with 3 points as 6 flat args.
      def filled_triangle(x1, y1, x2, y2, x3, y3, color=1)
        filled_polygon([[x1,y1], [x2,y2], [x3,y3]], color)
      end

      # Midpoint ellipse / circle based on Bresenham's circle algorithm.
      def ellipse(x_center, y_center, a, b, color=1, filled=false)
        # Start position
        x = -a
        y = 0

        # Precompute x and y increments for each step.
        x_increment = 2 * b * b
        y_increment = 2 * a * a

        # Start errors
        dx = (1 + (2 * x)) * b * b
        dy = x * x
        e1 = dx + dy
        e2 = dx

        # Since starting at max negative X, continue until x is 0.
        while (x <= 0)
          if filled
            fill_quadrants(x_center, y_center, x, y, color)
          else
            stroke_quadrants(x_center, y_center, x, y, color)
          end

          e2 = 2 * e1
          if (e2 >= dx)
            x  += 1
            dx += x_increment
            e1 += dx
          end
          if (e2 <= dy)
            y  += 1
            dy += y_increment
            e1 += dy
          end
        end

        # Continue if y hasn't reached the vertical size.
        while (y < b)
          y += 1
          pixel(x_center, y_center + y, color)
          pixel(x_center, y_center - y, color)
        end
      end

      def stroke_quadrants(x_center, y_center, x, y, color)
        # Quadrants in order as if y-axis is reversed and going counter-clockwise from +ve X.
        pixel(x_center - x, y_center - y, color)
        pixel(x_center + x, y_center - y, color)
        pixel(x_center + x, y_center + y, color)
        pixel(x_center - x, y_center + y, color)
      end

      def fill_quadrants(x_center, y_center, x, y, color)
        line(x_center - x, y_center + y, x_center + x, y_center + y, color)
        line(x_center - x, y_center - y, x_center + x, y_center - y, color)
      end

      def circle(x_center, y_center, radius, color=1, filled=false)
        ellipse(x_center, y_center, radius, radius, color, filled)
      end

      def filled_circle(x_center, y_center, radius, color=1)
        ellipse(x_center, y_center, radius, radius, color, true)
      end

      def text_cursor=(array=[])
        @text_cursor = array
      end

      def text_cursor
        @text_cursor ||= [0, 7]
      end

      def print(str)
        str.to_s.split("").each do |char|
          print_char(char)
        end
      end

      def print_char(char)
        # 0th character in font is SPACE. Offset and limit to printable chars.
        index = char.ord - 32
        index = 0 if (index < 0 || index > 94)
        
        char_map = FONT_6x8[index]

        # Get the starting byte index
        page = text_cursor[1] / 8
        byte_index = (@columns * page) + text_cursor[0]

        # Replace those bytes in the framebuffer with the character.
        char_map.each do |byte| 
          @framebuffer[byte_index] = byte
          byte_index += 1
        end

        # Increment the text cursor.
        self.text_cursor[0] += 6
      end
    end
  end
end
