library animation_optimizer_spec;

import '../_specs.dart';

run(bool animationsEnabled) {
  describe('AnimationLoop: animationsEnabled=$animationsEnabled', () {
    TestBed _;
    AnimationOptimizer optimizer;
    beforeEach(inject((TestBed tb, Expando expand) {
      _ = tb;
      optimizer = new AnimationOptimizer(expand)..animationsEnabled = animationsEnabled;
    }));
    
    it('should prevent animations on child elements', () {
      var animation = new NoOpAnimation();
      _.compile('<div><div></div></div>');
      

      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
      optimizer.track(animation, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      optimizer.forget(animation);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
    });
    
    it('should allow multiple animations on the same element', () {
      var animation1 = new NoOpAnimation();
      var animation2 = new NoOpAnimation();
      _.compile('<div><div></div></div>');
      
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      optimizer.track(animation1, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      optimizer.track(animation2, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      optimizer.forget(animation1);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      optimizer.forget(animation2);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
    });

    it('should always animate an element', () {
      _.compile('<div><div></div></div>');
      optimizer.alwaysAnimate(_.rootElement.children[0], "never");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      optimizer.alwaysAnimate(_.rootElement.children[0], "always");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
      optimizer.alwaysAnimate(_.rootElement.children[0], "auto");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
    });

    it('alwaysAnimate should not affect children', () {
      _.compile('<div><div></div></div>');
      optimizer.alwaysAnimate(_.rootElement, "never");
      expect(optimizer.shouldAnimate(_.rootElement)).toBeFalsy();
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
      optimizer.alwaysAnimate(_.rootElement, "always");
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
      optimizer.alwaysAnimate(_.rootElement, "auto");
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
    });


    it('alwaysAnimateChildren should not affect element', () {
      _.compile('<div><div></div></div>');

      optimizer.alwaysAnimateChildren(_.rootElement, "never");
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();

      optimizer.alwaysAnimateChildren(_.rootElement, "always");
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);

      optimizer.alwaysAnimateChildren(_.rootElement, "auto");
      expect(optimizer.shouldAnimate(_.rootElement)).toBe(animationsEnabled);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
    });

    it('alwaysAnimate should take priority over alwaysAnimateChildren', () {
      _.compile('<div><div></div></div>');

      optimizer.alwaysAnimateChildren(_.rootElement, "never");
      optimizer.alwaysAnimate(_.rootElement.children[0], "always");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);

      optimizer.alwaysAnimateChildren(_.rootElement, "always");
      optimizer.alwaysAnimate(_.rootElement.children[0], "never");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
    });

    it('alwaysAnimate should take priority over running animations', () {
      _.compile('<div><div></div></div>');
      var animation = new NoOpAnimation();

      optimizer.track(animation, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();

      optimizer.alwaysAnimate(_.rootElement.children[0], "always");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);

      optimizer.alwaysAnimate(_.rootElement.children[0], "auto");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();

      optimizer.forget(animation);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);
    });

    it('alwaysAnimateChildren should take priority over running animations',
        () {
      _.compile('<div><div></div></div>');
      var animation = new NoOpAnimation();

      optimizer.track(animation, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();

      optimizer.alwaysAnimateChildren(_.rootElement, "always");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);

      optimizer.alwaysAnimateChildren(_.rootElement, "auto");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();

      optimizer.forget(animation);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBe(animationsEnabled);

      optimizer.alwaysAnimateChildren(_.rootElement, "never");
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
    });


    it('alwaysAnimateChildren when nested should prioritize the closest'
    +'element up the tree.',
        () {
      _.compile('<div><div><div></div></div></div>');

      optimizer.alwaysAnimateChildren(_.rootElement, "always");
      expect(optimizer.shouldAnimate(_.rootElement.children[0].children[0]))
        .toBe(animationsEnabled);

      optimizer.alwaysAnimateChildren(_.rootElement.children[0], "never");
      expect(optimizer.shouldAnimate(_.rootElement.children[0].children[0]))
        .toBeFalsy();


      optimizer.alwaysAnimateChildren(_.rootElement, "never");
      optimizer.alwaysAnimateChildren(_.rootElement.children[0], "always");
      expect(optimizer.shouldAnimate(_.rootElement.children[0].children[0]))
        .toBe(animationsEnabled);
    });
  });
}

main() {
  [true, false].forEach(run);
}
