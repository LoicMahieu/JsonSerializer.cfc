component
	extends = "TestCase"
	output = false
	hint = "I test the Json Serializer component."
	{


	// Set up the serializer before all tests.
	public void function setup() {

		serializer = new lib.JsonSerializer()
			.asInteger( "age" )
			.asDate( "dateOfBirth" )
			.asInteger( "duration" )
			.asString( "favoriteColors" )
			.asString( "favoriteMovies" )
			.asString( "firstName" )
			.asString( "hex" )
			.asInteger( "id" )
			.asString( "lastName" )
			.exclude( "password" )
			.asBoolean( "quizAnswers" )
			.asFloat( "rating" )
		;

		user = {
			firstName = "Tricia",
			lastName = "Smith",
			age = 33,
			dateOfBirth = "1980/01/01",
			nickName = "Trish",
			password = "I<3ColdFusion"
		};

		movies = queryNew( "" );

		queryAddColumn( movies, "id", "cf_sql_integer", [ 1, 2, 3 ] );
		queryAddColumn( movies, "name", "cf_sql_varchar", [ "Movie A", "Movie B", "Movie C" ] );
		queryAddColumn( movies, "rating", "cf_sql_decimal", [ 3, 3.5, 4.5 ] );
		queryAddColumn( movies, "duration", "cf_sql_integer", [ 122, 96, 108 ] );

		user.favoriteMovies = movies;

		colors = [
			{
				hex = "333333",
				name = "Color 1"
			},
			{
				hex = "666666",
				name = "Color 2"
			},
			{
				hex = "999999",
				name = "Color 3"
			},
			{
				hex = "AAAAAA",
				name = "Color 4"
			},
			{
				hex = "CCCCCC",
				name = "Color 5"
			},
			{
				hex = "FFFFFF",
				name = "Color 6"
			}
		];

		user.favoriteColors = colors;

		quizAnswers = [ 1, 1, 0, 1 ];

		user.quizAnswers = quizAnswers;

	}


	// ---
	// TEST METHODS.
	// ---


	public void function testStructSerializationLifecycle() {

		var input = user;

		var serializedInput = serializer.serialize( input );
		var deserializedInput = deserializeJson( serializedInput );

		assert( isStruct( deserializedInput ) );

	}


	public void function testArraySerializationLifecycle() {

		var input = colors;

		var serializedInput = serializer.serialize( input );
		var deserializedInput = deserializeJson( serializedInput );

		assert( isArray( deserializedInput ) );

	}


	public void function testQuerySerializationLifecycle() {

		var input = movies;

		var serializedInput = serializer.serialize( input );
		var deserializedInput = deserializeJson( serializedInput );

		assert( isArray( deserializedInput ) );

	}


	public void function testNumberSerializationLifecycle() {

		var serializedInput = serializer.serialize( 4 );
		var deserializedInput = deserializeJson( serializedInput );

		assert( isNumeric( deserializedInput ) );

	}


	public void function testStringSerializationLifecycle() {

		var serializedInput = serializer.serialize( "Hello" );
		var deserializedInput = deserializeJson( serializedInput );

		assert( isSimpleValue( deserializedInput ) );

	}


	public void function testBooleanSerializationLifecycle() {

		var serializedInput = serializer.serialize( false );
		var deserializedInput = deserializeJson( serializedInput );

		assert( isBoolean( deserializedInput ) );

	}


	public void function testTopLevelStruct() {

		var input = user;

		var serializedInput = serializer.serialize( user );

		assertUserValues( serializedInput );
		assertMovieValues( serializedInput );
		assertColorValues( serializedInput );
		assertQuizAnswerValues( serializedInput );

	}


	public void function testTopLevelArray() {

		var input = [ user ];

		var serializedInput = serializer.serialize( input );

		assertUserValues( serializedInput );
		assertMovieValues( serializedInput );
		assertColorValues( serializedInput );
		assertQuizAnswerValues( serializedInput );

	}


	public void function testTopLevelQuery() {

		var input = movies;

		var serializedInput = serializer.serialize( input );

		assertMovieValues( serializedInput );

	}


	public void function testBuggySerialization() {

		// This tests a bug introduced in ColdFusion 10.0.14 that incorrectly converts
		// character strings into unicode escape sequences:
		// --
		// Read more: http://www.bennadel.com/blog/2842-serializejson-and-the-input-and-output-encodings-are-not-same-errors-in-coldfusion.htm
		var input = "This value [ u+1234 ] is known to cause problems in ColdFusion.";

		var serializedInput = serializer.serialize( input );

		var deserializedInput = deserializeJson( serializedInput );

		assert( input == deserializedInput );

	}

	public void function testTabInNumeric() {
		var serializer = new lib.JsonSerializer();
		var tab = '	';
		var input = { name: "#tab#12456" };

		var serializedInput = serializer.serialize( input );

		assertEquals(serializedInput, '{"name":"\t12456"}');
	}


	// ---
	// PRIVATE METHODS.
	// ---


	public void function assertColorValues( required string serializedInput ) {

		// Test the keys.
		assert( find( quote( "hex" ), serializedInput ) );
		assert( find( quote( "name" ), serializedInput ) );

		// Test the values.
		assert( find( quote( "333333" ), serializedInput ) );
		assert( find( quote( "666666" ), serializedInput ) );
		assert( find( quote( "999999" ), serializedInput ) );
		assert( find( quote( "AAAAAA" ), serializedInput ) );
		assert( find( quote( "CCCCCC" ), serializedInput ) );
		assert( find( quote( "FFFFFF" ), serializedInput ) );

		assert( find( quote( "Color 1" ), serializedInput ) );
		assert( find( quote( "Color 2" ), serializedInput ) );
		assert( find( quote( "Color 3" ), serializedInput ) );
		assert( find( quote( "Color 4" ), serializedInput ) );
		assert( find( quote( "Color 5" ), serializedInput ) );
		assert( find( quote( "Color 6" ), serializedInput ) );

	}


	public void function assertMovieValues( required string serializedInput ) {

		// Test the keys.
		assert( find( quote( "id" ), serializedInput ) );
		assert( find( quote( "name" ), serializedInput ) );
		assert( find( quote( "duration" ), serializedInput ) );
		assert( find( quote( "rating" ), serializedInput ) );

		// Test the values.
		assert( find( ":1", serializedInput ) );
		assert( find( quote( "Movie A" ), serializedInput ) );
		assert( find( ":3", serializedInput ) );
		assert( find( ":122", serializedInput ) );

		assert( find( ":2", serializedInput ) );
		assert( find( quote( "Movie B" ), serializedInput ) );
		assert( find( ":3.5", serializedInput ) );
		assert( find( ":96", serializedInput ) );

		assert( find( ":3", serializedInput ) );
		assert( find( quote( "Movie C" ), serializedInput ) );
		assert( find( ":4.5", serializedInput ) );
		assert( find( ":108", serializedInput ) );

	}


	public void function assertQuizAnswerValues( required string serializedInput ) {

		// Test the values.
		assert( find( "true,true,false,true", serializedInput ) );

	}


	public void function assertUserValues( required string serializedInput ) {

		// Test the keys.
		assert( find( quote( "firstName" ), serializedInput ) );
		assert( find( quote( "lastName" ), serializedInput ) );
		assert( find( quote( "age" ), serializedInput ) );
		assert( find( quote( "dateOfBirth" ), serializedInput ) );
		assert( find( quote( "nickname" ), serializedInput ) );

		// Test the values.
		assert( find( quote( "Tricia" ), serializedInput ) );
		assert( find( quote( "Smith" ), serializedInput ) );
		assert( find( ":33", serializedInput ) );
		assert( find( quote( "1980-01-01T00:00:00.0Z" ), serializedInput ) );

		// Test excluded values.
		assert( ! findNoCase( quote( "password" ), serializedInput ) );

	}


	public string function quote( required string value ) {

		return( """#value#""" );

	}


}
