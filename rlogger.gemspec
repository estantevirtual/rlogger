lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'rlogger'
  s.version     = '0.1.2'
  s.date        = '2015-09-29'
  s.summary     = "RLogger"
  s.description = "Ruby default logger for EV Ruby Applications"
  s.authors     = ["Estante Virtual"]
  s.email       = 'equipe_ti@estantevirtual.com.br'
  s.require_paths = ["lib"]
  s.files       = ["lib/rlogger.rb"]
  s.homepage    = 'https://github.com/estantevirtual/rlogger'
  s.license     = 'MIT'
end
