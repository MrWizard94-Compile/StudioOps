/** @type {import('tailwindcss').Config} */
import __vite__cjsImport0_tailwindcssAnimate from "/node_modules/.vite/deps/tailwindcss-animate.js?v=a82bdfd4"; const tailwindcssAnimate = __vite__cjsImport0_tailwindcssAnimate.__esModule ? __vite__cjsImport0_tailwindcssAnimate.default : __vite__cjsImport0_tailwindcssAnimate;
export default {
  content: ['./index.html', './src/**/*.{ts,tsx,js,jsx}', './dev-tools/src/**/*.{ts,tsx,js,jsx}'],
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px'
      }
    },
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))'
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))'
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))'
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))'
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))'
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))'
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))'
        }
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)'
      },
      fontFamily: {
        sans: ['var(--font-sans)'],
        heading: ['var(--font-heading)'],
        serif: ['var(--font-serif)'],
        mono: ['var(--font-mono)']
      },
      keyframes: {
        'accordion-down': {
          from: {
            height: '0'
          },
          to: {
            height: 'var(--radix-accordion-content-height)'
          }
        },
        'accordion-up': {
          from: {
            height: 'var(--radix-accordion-content-height)'
          },
          to: {
            height: '0'
          }
        },
        float: {
          '0%, 100%': {
            transform: 'translateY(0px)'
          },
          '50%': {
            transform: 'translateY(-10px)'
          }
        },
        'rotate-clockwise': {
          '0%': {
            transform: 'rotate(0deg)'
          },
          '100%': {
            transform: 'rotate(360deg)'
          }
        },
        'rotate-counter': {
          '0%': {
            transform: 'rotate(0deg)'
          },
          '100%': {
            transform: 'rotate(-360deg)'
          }
        },
        'accordion-down': {
          from: {
            height: '0'
          },
          to: {
            height: 'var(--radix-accordion-content-height)'
          }
        },
        'accordion-up': {
          from: {
            height: 'var(--radix-accordion-content-height)'
          },
          to: {
            height: '0'
          }
        }
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
        'spin-slow': 'spin 3s linear infinite',
        'pulse-slow': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'bounce-gentle': 'bounce 2s infinite',
        float: 'float 3s ease-in-out infinite',
        'rotate-clockwise': 'rotate-clockwise 4s linear infinite',
        'rotate-counter': 'rotate-counter 3s linear infinite',
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out'
      }
    }
  },
  plugins: [tailwindcssAnimate]
};
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJuYW1lcyI6WyJ0YWlsd2luZGNzc0FuaW1hdGUiLCJjb250ZW50IiwidGhlbWUiLCJjb250YWluZXIiLCJjZW50ZXIiLCJwYWRkaW5nIiwic2NyZWVucyIsImV4dGVuZCIsImNvbG9ycyIsImJvcmRlciIsImlucHV0IiwicmluZyIsImJhY2tncm91bmQiLCJmb3JlZ3JvdW5kIiwicHJpbWFyeSIsIkRFRkFVTFQiLCJzZWNvbmRhcnkiLCJkZXN0cnVjdGl2ZSIsIm11dGVkIiwiYWNjZW50IiwicG9wb3ZlciIsImNhcmQiLCJib3JkZXJSYWRpdXMiLCJsZyIsIm1kIiwic20iLCJmb250RmFtaWx5Iiwic2FucyIsImhlYWRpbmciLCJzZXJpZiIsIm1vbm8iLCJrZXlmcmFtZXMiLCJmcm9tIiwiaGVpZ2h0IiwidG8iLCJmbG9hdCIsInRyYW5zZm9ybSIsImFuaW1hdGlvbiIsInBsdWdpbnMiXSwic291cmNlcyI6WyJ0YWlsd2luZC5jb25maWcuanMiXSwic291cmNlc0NvbnRlbnQiOlsiLyoqIEB0eXBlIHtpbXBvcnQoJ3RhaWx3aW5kY3NzJykuQ29uZmlnfSAqL1xuaW1wb3J0IHRhaWx3aW5kY3NzQW5pbWF0ZSBmcm9tICd0YWlsd2luZGNzcy1hbmltYXRlJ1xuXG5leHBvcnQgZGVmYXVsdCB7XG4gIGNvbnRlbnQ6IFtcbiAgICAnLi9pbmRleC5odG1sJyxcbiAgICAnLi9zcmMvKiovKi57dHMsdHN4LGpzLGpzeH0nLFxuICAgICcuL2Rldi10b29scy9zcmMvKiovKi57dHMsdHN4LGpzLGpzeH0nLFxuICBdLFxuICB0aGVtZToge1xuICBcdGNvbnRhaW5lcjoge1xuICBcdFx0Y2VudGVyOiB0cnVlLFxuICBcdFx0cGFkZGluZzogJzJyZW0nLFxuICBcdFx0c2NyZWVuczoge1xuICBcdFx0XHQnMnhsJzogJzE0MDBweCdcbiAgXHRcdH1cbiAgXHR9LFxuICBcdGV4dGVuZDoge1xuICBcdFx0Y29sb3JzOiB7XG4gIFx0XHRcdGJvcmRlcjogJ2hzbCh2YXIoLS1ib3JkZXIpKScsXG4gIFx0XHRcdGlucHV0OiAnaHNsKHZhcigtLWlucHV0KSknLFxuICBcdFx0XHRyaW5nOiAnaHNsKHZhcigtLXJpbmcpKScsXG4gIFx0XHRcdGJhY2tncm91bmQ6ICdoc2wodmFyKC0tYmFja2dyb3VuZCkpJyxcbiAgXHRcdFx0Zm9yZWdyb3VuZDogJ2hzbCh2YXIoLS1mb3JlZ3JvdW5kKSknLFxuICBcdFx0XHRwcmltYXJ5OiB7XG4gIFx0XHRcdFx0REVGQVVMVDogJ2hzbCh2YXIoLS1wcmltYXJ5KSknLFxuICBcdFx0XHRcdGZvcmVncm91bmQ6ICdoc2wodmFyKC0tcHJpbWFyeS1mb3JlZ3JvdW5kKSknXG4gIFx0XHRcdH0sXG4gIFx0XHRcdHNlY29uZGFyeToge1xuICBcdFx0XHRcdERFRkFVTFQ6ICdoc2wodmFyKC0tc2Vjb25kYXJ5KSknLFxuICBcdFx0XHRcdGZvcmVncm91bmQ6ICdoc2wodmFyKC0tc2Vjb25kYXJ5LWZvcmVncm91bmQpKSdcbiAgXHRcdFx0fSxcbiAgXHRcdFx0ZGVzdHJ1Y3RpdmU6IHtcbiAgXHRcdFx0XHRERUZBVUxUOiAnaHNsKHZhcigtLWRlc3RydWN0aXZlKSknLFxuICBcdFx0XHRcdGZvcmVncm91bmQ6ICdoc2wodmFyKC0tZGVzdHJ1Y3RpdmUtZm9yZWdyb3VuZCkpJ1xuICBcdFx0XHR9LFxuICBcdFx0XHRtdXRlZDoge1xuICBcdFx0XHRcdERFRkFVTFQ6ICdoc2wodmFyKC0tbXV0ZWQpKScsXG4gIFx0XHRcdFx0Zm9yZWdyb3VuZDogJ2hzbCh2YXIoLS1tdXRlZC1mb3JlZ3JvdW5kKSknXG4gIFx0XHRcdH0sXG4gIFx0XHRcdGFjY2VudDoge1xuICBcdFx0XHRcdERFRkFVTFQ6ICdoc2wodmFyKC0tYWNjZW50KSknLFxuICBcdFx0XHRcdGZvcmVncm91bmQ6ICdoc2wodmFyKC0tYWNjZW50LWZvcmVncm91bmQpKSdcbiAgXHRcdFx0fSxcbiAgXHRcdFx0cG9wb3Zlcjoge1xuICBcdFx0XHRcdERFRkFVTFQ6ICdoc2wodmFyKC0tcG9wb3ZlcikpJyxcbiAgXHRcdFx0XHRmb3JlZ3JvdW5kOiAnaHNsKHZhcigtLXBvcG92ZXItZm9yZWdyb3VuZCkpJ1xuICBcdFx0XHR9LFxuICBcdFx0XHRjYXJkOiB7XG4gIFx0XHRcdFx0REVGQVVMVDogJ2hzbCh2YXIoLS1jYXJkKSknLFxuICBcdFx0XHRcdGZvcmVncm91bmQ6ICdoc2wodmFyKC0tY2FyZC1mb3JlZ3JvdW5kKSknXG4gIFx0XHRcdH1cbiAgXHRcdH0sXG4gIFx0XHRib3JkZXJSYWRpdXM6IHtcbiAgXHRcdFx0bGc6ICd2YXIoLS1yYWRpdXMpJyxcbiAgXHRcdFx0bWQ6ICdjYWxjKHZhcigtLXJhZGl1cykgLSAycHgpJyxcbiAgXHRcdFx0c206ICdjYWxjKHZhcigtLXJhZGl1cykgLSA0cHgpJ1xuICBcdFx0fSxcblx0XHRmb250RmFtaWx5OiB7XG5cdFx0XHRzYW5zOiBbJ3ZhcigtLWZvbnQtc2FucyknXSxcblx0XHRcdGhlYWRpbmc6IFsndmFyKC0tZm9udC1oZWFkaW5nKSddLFxuXHRcdFx0c2VyaWY6IFsndmFyKC0tZm9udC1zZXJpZiknXSxcblx0XHRcdG1vbm86IFsndmFyKC0tZm9udC1tb25vKSddXG5cdFx0fSxcbiAgXHRcdGtleWZyYW1lczoge1xuICBcdFx0XHQnYWNjb3JkaW9uLWRvd24nOiB7XG4gIFx0XHRcdFx0ZnJvbToge1xuICBcdFx0XHRcdFx0aGVpZ2h0OiAnMCdcbiAgXHRcdFx0XHR9LFxuICBcdFx0XHRcdHRvOiB7XG4gIFx0XHRcdFx0XHRoZWlnaHQ6ICd2YXIoLS1yYWRpeC1hY2NvcmRpb24tY29udGVudC1oZWlnaHQpJ1xuICBcdFx0XHRcdH1cbiAgXHRcdFx0fSxcbiAgXHRcdFx0J2FjY29yZGlvbi11cCc6IHtcbiAgXHRcdFx0XHRmcm9tOiB7XG4gIFx0XHRcdFx0XHRoZWlnaHQ6ICd2YXIoLS1yYWRpeC1hY2NvcmRpb24tY29udGVudC1oZWlnaHQpJ1xuICBcdFx0XHRcdH0sXG4gIFx0XHRcdFx0dG86IHtcbiAgXHRcdFx0XHRcdGhlaWdodDogJzAnXG4gIFx0XHRcdFx0fVxuICBcdFx0XHR9LFxuICBcdFx0XHRmbG9hdDoge1xuICBcdFx0XHRcdCcwJSwgMTAwJSc6IHtcbiAgXHRcdFx0XHRcdHRyYW5zZm9ybTogJ3RyYW5zbGF0ZVkoMHB4KSdcbiAgXHRcdFx0XHR9LFxuICBcdFx0XHRcdCc1MCUnOiB7XG4gIFx0XHRcdFx0XHR0cmFuc2Zvcm06ICd0cmFuc2xhdGVZKC0xMHB4KSdcbiAgXHRcdFx0XHR9XG4gIFx0XHRcdH0sXG4gIFx0XHRcdCdyb3RhdGUtY2xvY2t3aXNlJzoge1xuICBcdFx0XHRcdCcwJSc6IHtcbiAgXHRcdFx0XHRcdHRyYW5zZm9ybTogJ3JvdGF0ZSgwZGVnKSdcbiAgXHRcdFx0XHR9LFxuICBcdFx0XHRcdCcxMDAlJzoge1xuICBcdFx0XHRcdFx0dHJhbnNmb3JtOiAncm90YXRlKDM2MGRlZyknXG4gIFx0XHRcdFx0fVxuICBcdFx0XHR9LFxuICBcdFx0XHQncm90YXRlLWNvdW50ZXInOiB7XG4gIFx0XHRcdFx0JzAlJzoge1xuICBcdFx0XHRcdFx0dHJhbnNmb3JtOiAncm90YXRlKDBkZWcpJ1xuICBcdFx0XHRcdH0sXG4gIFx0XHRcdFx0JzEwMCUnOiB7XG4gIFx0XHRcdFx0XHR0cmFuc2Zvcm06ICdyb3RhdGUoLTM2MGRlZyknXG4gIFx0XHRcdFx0fVxuICBcdFx0XHR9LFxuICBcdFx0XHQnYWNjb3JkaW9uLWRvd24nOiB7XG4gIFx0XHRcdFx0ZnJvbToge1xuICBcdFx0XHRcdFx0aGVpZ2h0OiAnMCdcbiAgXHRcdFx0XHR9LFxuICBcdFx0XHRcdHRvOiB7XG4gIFx0XHRcdFx0XHRoZWlnaHQ6ICd2YXIoLS1yYWRpeC1hY2NvcmRpb24tY29udGVudC1oZWlnaHQpJ1xuICBcdFx0XHRcdH1cbiAgXHRcdFx0fSxcbiAgXHRcdFx0J2FjY29yZGlvbi11cCc6IHtcbiAgXHRcdFx0XHRmcm9tOiB7XG4gIFx0XHRcdFx0XHRoZWlnaHQ6ICd2YXIoLS1yYWRpeC1hY2NvcmRpb24tY29udGVudC1oZWlnaHQpJ1xuICBcdFx0XHRcdH0sXG4gIFx0XHRcdFx0dG86IHtcbiAgXHRcdFx0XHRcdGhlaWdodDogJzAnXG4gIFx0XHRcdFx0fVxuICBcdFx0XHR9XG4gIFx0XHR9LFxuICBcdFx0YW5pbWF0aW9uOiB7XG4gIFx0XHRcdCdhY2NvcmRpb24tZG93bic6ICdhY2NvcmRpb24tZG93biAwLjJzIGVhc2Utb3V0JyxcbiAgXHRcdFx0J2FjY29yZGlvbi11cCc6ICdhY2NvcmRpb24tdXAgMC4ycyBlYXNlLW91dCcsXG4gIFx0XHRcdCdzcGluLXNsb3cnOiAnc3BpbiAzcyBsaW5lYXIgaW5maW5pdGUnLFxuICBcdFx0XHQncHVsc2Utc2xvdyc6ICdwdWxzZSAycyBjdWJpYy1iZXppZXIoMC40LCAwLCAwLjYsIDEpIGluZmluaXRlJyxcbiAgXHRcdFx0J2JvdW5jZS1nZW50bGUnOiAnYm91bmNlIDJzIGluZmluaXRlJyxcbiAgXHRcdFx0ZmxvYXQ6ICdmbG9hdCAzcyBlYXNlLWluLW91dCBpbmZpbml0ZScsXG4gIFx0XHRcdCdyb3RhdGUtY2xvY2t3aXNlJzogJ3JvdGF0ZS1jbG9ja3dpc2UgNHMgbGluZWFyIGluZmluaXRlJyxcbiAgXHRcdFx0J3JvdGF0ZS1jb3VudGVyJzogJ3JvdGF0ZS1jb3VudGVyIDNzIGxpbmVhciBpbmZpbml0ZScsXG4gIFx0XHRcdCdhY2NvcmRpb24tZG93bic6ICdhY2NvcmRpb24tZG93biAwLjJzIGVhc2Utb3V0JyxcbiAgXHRcdFx0J2FjY29yZGlvbi11cCc6ICdhY2NvcmRpb24tdXAgMC4ycyBlYXNlLW91dCdcbiAgXHRcdH1cbiAgXHR9XG4gIH0sXG4gIHBsdWdpbnM6IFt0YWlsd2luZGNzc0FuaW1hdGVdLFxufVxuIl0sIm1hcHBpbmdzIjoiQUFBQTtBQUNBLE9BQU9BLGtCQUFrQixNQUFNLHFCQUFxQjtBQUVwRCxlQUFlO0VBQ2JDLE9BQU8sRUFBRSxDQUNQLGNBQWMsRUFDZCw0QkFBNEIsRUFDNUIsc0NBQXNDLENBQ3ZDO0VBQ0RDLEtBQUssRUFBRTtJQUNOQyxTQUFTLEVBQUU7TUFDVkMsTUFBTSxFQUFFLElBQUk7TUFDWkMsT0FBTyxFQUFFLE1BQU07TUFDZkMsT0FBTyxFQUFFO1FBQ1IsS0FBSyxFQUFFO01BQ1I7SUFDRCxDQUFDO0lBQ0RDLE1BQU0sRUFBRTtNQUNQQyxNQUFNLEVBQUU7UUFDUEMsTUFBTSxFQUFFLG9CQUFvQjtRQUM1QkMsS0FBSyxFQUFFLG1CQUFtQjtRQUMxQkMsSUFBSSxFQUFFLGtCQUFrQjtRQUN4QkMsVUFBVSxFQUFFLHdCQUF3QjtRQUNwQ0MsVUFBVSxFQUFFLHdCQUF3QjtRQUNwQ0MsT0FBTyxFQUFFO1VBQ1JDLE9BQU8sRUFBRSxxQkFBcUI7VUFDOUJGLFVBQVUsRUFBRTtRQUNiLENBQUM7UUFDREcsU0FBUyxFQUFFO1VBQ1ZELE9BQU8sRUFBRSx1QkFBdUI7VUFDaENGLFVBQVUsRUFBRTtRQUNiLENBQUM7UUFDREksV0FBVyxFQUFFO1VBQ1pGLE9BQU8sRUFBRSx5QkFBeUI7VUFDbENGLFVBQVUsRUFBRTtRQUNiLENBQUM7UUFDREssS0FBSyxFQUFFO1VBQ05ILE9BQU8sRUFBRSxtQkFBbUI7VUFDNUJGLFVBQVUsRUFBRTtRQUNiLENBQUM7UUFDRE0sTUFBTSxFQUFFO1VBQ1BKLE9BQU8sRUFBRSxvQkFBb0I7VUFDN0JGLFVBQVUsRUFBRTtRQUNiLENBQUM7UUFDRE8sT0FBTyxFQUFFO1VBQ1JMLE9BQU8sRUFBRSxxQkFBcUI7VUFDOUJGLFVBQVUsRUFBRTtRQUNiLENBQUM7UUFDRFEsSUFBSSxFQUFFO1VBQ0xOLE9BQU8sRUFBRSxrQkFBa0I7VUFDM0JGLFVBQVUsRUFBRTtRQUNiO01BQ0QsQ0FBQztNQUNEUyxZQUFZLEVBQUU7UUFDYkMsRUFBRSxFQUFFLGVBQWU7UUFDbkJDLEVBQUUsRUFBRSwyQkFBMkI7UUFDL0JDLEVBQUUsRUFBRTtNQUNMLENBQUM7TUFDSEMsVUFBVSxFQUFFO1FBQ1hDLElBQUksRUFBRSxDQUFDLGtCQUFrQixDQUFDO1FBQzFCQyxPQUFPLEVBQUUsQ0FBQyxxQkFBcUIsQ0FBQztRQUNoQ0MsS0FBSyxFQUFFLENBQUMsbUJBQW1CLENBQUM7UUFDNUJDLElBQUksRUFBRSxDQUFDLGtCQUFrQjtNQUMxQixDQUFDO01BQ0NDLFNBQVMsRUFBRTtRQUNWLGdCQUFnQixFQUFFO1VBQ2pCQyxJQUFJLEVBQUU7WUFDTEMsTUFBTSxFQUFFO1VBQ1QsQ0FBQztVQUNEQyxFQUFFLEVBQUU7WUFDSEQsTUFBTSxFQUFFO1VBQ1Q7UUFDRCxDQUFDO1FBQ0QsY0FBYyxFQUFFO1VBQ2ZELElBQUksRUFBRTtZQUNMQyxNQUFNLEVBQUU7VUFDVCxDQUFDO1VBQ0RDLEVBQUUsRUFBRTtZQUNIRCxNQUFNLEVBQUU7VUFDVDtRQUNELENBQUM7UUFDREUsS0FBSyxFQUFFO1VBQ04sVUFBVSxFQUFFO1lBQ1hDLFNBQVMsRUFBRTtVQUNaLENBQUM7VUFDRCxLQUFLLEVBQUU7WUFDTkEsU0FBUyxFQUFFO1VBQ1o7UUFDRCxDQUFDO1FBQ0Qsa0JBQWtCLEVBQUU7VUFDbkIsSUFBSSxFQUFFO1lBQ0xBLFNBQVMsRUFBRTtVQUNaLENBQUM7VUFDRCxNQUFNLEVBQUU7WUFDUEEsU0FBUyxFQUFFO1VBQ1o7UUFDRCxDQUFDO1FBQ0QsZ0JBQWdCLEVBQUU7VUFDakIsSUFBSSxFQUFFO1lBQ0xBLFNBQVMsRUFBRTtVQUNaLENBQUM7VUFDRCxNQUFNLEVBQUU7WUFDUEEsU0FBUyxFQUFFO1VBQ1o7UUFDRCxDQUFDO1FBQ0QsZ0JBQWdCLEVBQUU7VUFDakJKLElBQUksRUFBRTtZQUNMQyxNQUFNLEVBQUU7VUFDVCxDQUFDO1VBQ0RDLEVBQUUsRUFBRTtZQUNIRCxNQUFNLEVBQUU7VUFDVDtRQUNELENBQUM7UUFDRCxjQUFjLEVBQUU7VUFDZkQsSUFBSSxFQUFFO1lBQ0xDLE1BQU0sRUFBRTtVQUNULENBQUM7VUFDREMsRUFBRSxFQUFFO1lBQ0hELE1BQU0sRUFBRTtVQUNUO1FBQ0Q7TUFDRCxDQUFDO01BQ0RJLFNBQVMsRUFBRTtRQUNWLGdCQUFnQixFQUFFLDhCQUE4QjtRQUNoRCxjQUFjLEVBQUUsNEJBQTRCO1FBQzVDLFdBQVcsRUFBRSx5QkFBeUI7UUFDdEMsWUFBWSxFQUFFLGdEQUFnRDtRQUM5RCxlQUFlLEVBQUUsb0JBQW9CO1FBQ3JDRixLQUFLLEVBQUUsK0JBQStCO1FBQ3RDLGtCQUFrQixFQUFFLHFDQUFxQztRQUN6RCxnQkFBZ0IsRUFBRSxtQ0FBbUM7UUFDckQsZ0JBQWdCLEVBQUUsOEJBQThCO1FBQ2hELGNBQWMsRUFBRTtNQUNqQjtJQUNEO0VBQ0QsQ0FBQztFQUNERyxPQUFPLEVBQUUsQ0FBQ3RDLGtCQUFrQjtBQUM5QixDQUFDIiwiaWdub3JlTGlzdCI6W119