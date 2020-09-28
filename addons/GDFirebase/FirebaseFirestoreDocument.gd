extends Node

# A FirestoreDocument objects that holds all important values for a Firestore Document,
# @doc_name = name of the Firestore Document, which is the request PATH
# @doc_fields = fields held by Firestore Document, in APIs format
# created when requested from a `collection().get()` call
class_name FirestoreDocument

var document : Dictionary # the Document itself
var doc_fields : Dictionary   # only .fields
var doc_name : String         # only .name

func _init(doc : Dictionary = {}, doc_name : String = "", doc_fields : Dictionary = {}):
	self.document = doc
	self.doc_name = doc_name
	self.doc_fields = (doc_fields)

# Pass a dictionary { 'key' : 'value' } to format it in a APIs usable .fields 
func dict2fields(dict : Dictionary) -> Dictionary:
	var fields : Dictionary = dict
	var var_type : String = ""
	for field in dict.keys():
		match typeof(dict[field]):
			TYPE_NIL:
				var_type = "nullValue"
			TYPE_BOOL:
				var_type = "booleanValue"
			TYPE_INT:
				var_type = "integerValue"
			TYPE_REAL:
				var_type = "doubleValue"
			TYPE_STRING:
				var_type = "stringValue"
			TYPE_ARRAY:
				var_type = "arrayValue"
				dict[field] = array2fields(dict[field])
		fields[field] = { var_type : dict[field] }
	return {'fields' : fields}


func array2fields(array:Array):#prepare Array for firestore
	var new_array:Array
	new_array.resize(array.size())
	var var_type : String = ""
	for i in array.size():
		match typeof(array[i]):
			TYPE_NIL:
				var_type = "nullValue"
			TYPE_BOOL:
				var_type = "booleanValue"
			TYPE_INT:
				var_type = "integerValue"
			TYPE_REAL:
				var_type = "doubleValue"
			TYPE_STRING:
				var_type = "stringValue"
		new_array[i] = {var_type : array[i]}
	return {"values":new_array}
	
	
# Pass the .fields inside a Firestore Document to print out the Dictionary { 'key' : 'value' }
func fields2dict(doc : Object) -> Dictionary:
	var dict : Dictionary = doc.doc_fields
	for field in (doc.doc_fields).keys():
		if dict[field].keys()[0] == "arrayValue":
			dict[field] = array2dict((doc.doc_fields)[field].values()[0])
			continue
		dict[field] = (doc.doc_fields)[field].values()[0]
	return dict

func array2dict(array):
	var new_array:Array
	if array:
		for value in array["values"]:
			new_array.append(value[value.keys()[0]])
	return new_array
