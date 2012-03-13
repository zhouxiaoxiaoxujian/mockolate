package mockolate.ingredients
{
	import asx.array.first;
	import asx.array.last;
	import asx.array.pluck;
	import asx.array.some;
	import asx.array.every;
	import asx.array.empty;
	import asx.array.map;
	import asx.array.compact;

	import org.hamcrest.Matcher;
	import org.hamcrest.collection.*;
	import org.hamcrest.core.*;
	import org.hamcrest.object.*;

	use namespace mockolate_ingredient;

	public class Spy extends Couverture
	{
		private var _invocationMatcher:Matcher;
		private var _invocations:Array;

		public function Spy(mockolateInstance:Mockolate, invocation:Invocation, args:Array)
		{
			super(mockolateInstance);

			_invocationMatcher = new InvocationMatcher(invocation, args);
			_invocations = [];
		}

		override mockolate_ingredient function invoked(invocation:Invocation):Boolean
		{
			if (_invocationMatcher.matches(invocation))
			{
				_invocations.push(invocation);
			}

			return false;
		}

		public function get invocations():Array
		{
			return _invocations;
		}

		public function get firstInvocation():Invocation
		{
			return first(_invocations) as Invocation;
		}
		
		public function get lastInvocation():Invocation
		{
			return last(_invocations) as Invocation;
		}
		
		public function get arguments():Array
		{
			return pluck(_invocations, 'arguments');
		}
		
		public function get returnValues():Array
		{
			return pluck(_invocations, 'returnValue');
		}
		
		public function get errors():Array
		{
			return compact(pluck(_invocations, 'error'));
		}
		
		public function get called():Boolean
		{
			return !empty(_invocations);
		}
		
		public function get calledOnce():Boolean
		{
			return _invocations.length === 1;
		}
		
		public function get calledTwice():Boolean
		{
			return _invocations.length === 2;
		}
		
		public function get calledThrice():Boolean
		{
			return _invocations.length === 3;
		}
		
		public function calledWith(...args):Boolean
		{	
			return arrayMatchesAny(arguments, new ArgumentsMatcher(args));
		}
		
		public function calledWithExactly(...args):Boolean
		{
			return some(arguments, array.apply(null, map(args, equalTo)).matches);
		}
		
		public function alwaysCalledWith(...args):Boolean
		{
			return arrayMatchesAll(arguments, new ArgumentsMatcher(args));
		}
		
		public function alwaysCalledWithExactly(...args):Boolean
		{
			return every(arguments, array.apply(null, map(args, equalTo)).matches);
		}
		
		public function neverCalledWith(...args):Boolean
		{
			return !arrayMatchesAny(arguments, new ArgumentsMatcher(args));
		}
		
		public function threw(errorOrMatcher:Object = null):Boolean
		{
			trace('Spy.threw', errors.length, errorOrMatcher);

			return errorOrMatcher
				? !empty(errors) && arrayMatchesAny(errors, errorOrMatcher)
				: !empty(errors);
		}
		
		public function alwaysThrew(errorOrMatcher:Object = null):Boolean
		{
			trace('Spy.alwaysThrew', errors.length, errorOrMatcher);

			return errorOrMatcher
				? !empty(errors) && arrayMatchesAll(errors, errorOrMatcher)
				: !empty(errors) && errors.length === invocations.length;
		}
		
		public function returned(valueOrMatcher:*):Boolean
		{
			return arrayMatchesAny(returnValues, valueOrMatcher);
		}
		
		public function alwaysReturned(valueOrMatcher:*):Boolean
		{
			return arrayMatchesAll(returnValues, valueOrMatcher);
		}

		private function arrayMatchesAny(array:Array, valueOrMatcher:*):Boolean 
		{
			return some(array, valueToMatcher(valueOrMatcher).matches);
		}

		private function arrayMatchesAll(array:Array, valueOrMatcher:*):Boolean 
		{
			return every(array, valueToMatcher(valueOrMatcher).matches);
		}
	}
}
