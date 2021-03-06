package mockolate.issues
{
	import mockolate.errors.ExpectationError;
	import mockolate.errors.InvocationError;
	import mockolate.runner.MockolateRule;
	
	import org.flexunit.asserts.fail;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.anything;
	import org.hamcrest.text.containsString;
	import org.hamcrest.text.re;

	public class Issue33_DefaultInvocationCount
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock]
		public var type:Issue33_Type;
		
		[Mock(type="strict")]
		public var entity1:Issue33_Entity;
		
		[Mock]
		public var entity2:Issue33_Entity;
		
		[Test(verify="false")]
		public function mock_shouldDefaultToAtLeastOnce():void 
		{
			try 
			{
				mocks.mock(entity1).getter("proxyKey").returns("ABCDEFG");
				mocks.verify(entity1);

				fail("expecting ExpectationError, no error thrown.");
			}
			catch (e:ExpectationError)
			{			
				assertThat(e.message, containsString("1 unmet Expectation"));
			}
		}
		
		[Test(verify="false")]
		public function never_should_should_complain_on_verification():void 
		{
			try
			{
				mocks.stub( type ).getter( "properties" ).returns( [] );
				mocks.stub( entity2 ).getter( "proxyKey" ).returns( "ABCDEFG" );
				mocks.mock( entity1 ).setter( "proxyKey" ).arg(anything()).never();
				
				entity1.proxyKey = entity2.proxyKey;

				mocks.verify( entity1 );

				fail("expecting ExpectationError, no error thrown");
			}
			catch (error:ExpectationError)
			{
				assertThat(error.message, containsString("1 unmet Expectation\n\tmockolate.issues::Issue33_Entity(entity1)#proxyKey = ANYTHING"));
				assertThat(error.message, containsString("should to be invoked never but was invoked <1> times"));
			}
		}
		
		[Test(verify="false")]
		public function twice_shouldFailOnThirdInvocation():void 
		{
			mocks.mock(entity2).getter("proxyKey").returns("first", "second", "third").twice();
			
			var first:String = entity2.proxyKey;
			var second:String = entity2.proxyKey;
			var third:String = entity2.proxyKey;
			
			try
			{
				mocks.verify(entity2);
					
				fail("expecting ExpectationError, no error thrown");
			}
			catch (error:ExpectationError)
			{
				assertThat(error.message, re(/unexpected invocation/i));
			}
			
		}
	}
}