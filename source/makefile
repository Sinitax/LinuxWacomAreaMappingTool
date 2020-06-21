LDLIBS = -lGL -lGLU -lglut -lX11 -lcairo
CXXFLAGS = --std=c++1z

.PHONY: all
all: bin/overlay_mapping bin/window_mapping

bin:
	mkdir bin

bin/overlay_mapping: src/overlay_mapping.cpp | bin
	$(CXX) $^ -o $@ $(LDLIBS) $(CXXFLAGS)

bin/window_mapping: src/window_mapping.cpp | bin
	$(CXX) $^ -o $@ $(LDLIBS) $(CXXFLAGS)

.PHONY: clean
clean:
	rm -rf bin/
