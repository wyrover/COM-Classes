/*
class: StructBase
serves as base class for struct classes. Struct classes must derive from it.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/StructBase)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_
	Other classes - CCFramework
*/
class StructBase extends _CCF_Error_Handler_
{
	/*
	group: private
	These methods and fields are for use by this class only.

	Field: buffers
	an array holding the buffers alocated by this struct instance. For internal use only.
	*/
	buffers := []

	/*
	Method: FindBufferKey
	finds a specified buffer in the <buffers> array and returns its index. For internal use only.

	Parameters:
		UPTR buffer - the buffer to find

	Returns:
		UINT key - the array index, or 0 if not found
	*/
	FindBufferKey(buffer)
	{
		local key, val
		for key, val in this.buffers
		{
			if (val == buffer)
			{
				return val
			}
		}
		return 0
	}

	/*
	Method: deconstructor
	called when the instance is released. Frees all allocated memory.

	Remarks:
		You do not call ths method from your code. Instead, AutoHotkey calls it when the istance is no longer needed.
	*/
	__Delete()
	{
		local index, buffer
		for index, buffer in this.buffers
		{
			this.Free(buffer)
		}
		this.buffers.SetCapacity(0)
	}

	/*
	group: protected
	These methods are intended for use by derived classes.

	Method: Allocate
	allocates a specified amount of bytes from the heap and returns a handle to it. The buffer is initalzed with 0.

	Parameters:
		UINT bytes - the number of bytes to allocate

	Returns:
		UPTR buffer - a pointer to the buffer allocated

	Remarks:
		This function should be used to allocate memory when <ToStructPtr()> is called withot a pointer.
	*/
	Allocate(bytes)
	{
		local buffer
		buffer := CCFramework.AllocateMemory(bytes)
		if (buffer)
		{
			this.buffers.Insert(buffer)
		}
		return buffer
	}

	/*
	Method: Free
	frees the memory of a given buffer.

	Parameters:
		UPTR buffer - a pointer to a buffer returned by <Allocate()>.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		Call this method if you're sure the memory is no longer needed. The <deconstructor> automatically calls this on all <buffers>.
	*/
	Free(buffer)
	{
		local bool
		bool := CCFramework.FreeMemory(buffer)
		if (bool)
		{
			this.buffers.Remove(this.FindBufferKey(buffer))
		}
		return bool
	}

	/*
	group: abstract methods
	These are methods derived classes must implement.

	Method: ToStructPtr
	abstract method that copies the values of an instance to a memory pointer. Derived classes must override this.

	Parameters:
		[opt] UPTR ptr - the fixed memory address to copy the struct to.

	Returns:
		UPTR ptr - a pointer to the struct in memory

	Developer Remarks:
		If no pointer is supplied, call <Allocate()>.
	*/
	ToStructPtr(ptr := 0)
	{
		throw Exception("Abstract method was not overriden.", -1)
	}

	/*
	Method: FromStructPtr
	abstract method that creates an instance of the struct class from a memory pointer. Derived classes must override this.

	Parameters:
		UPTR ptr - a pointer to a struct in memory

	Returns:
		OBJECT instance - the new instance
	*/
	FromStructPtr(ptr)
	{
		throw Exception("Abstract method was not overridden.", -1)
	}

	/*
	Method: GetRequiredSize
	abstract method that calculates the size a memory instance of this class requires.

	Parameters:
		[opt] OBJECT data - an optional data object that may cotain data for the calculation.

	Returns:
		UINT bytes - the number of bytes required

	Developer Remarks:
		- Implement this method so that it can be called as if t was a staic method: do not depend on instance fields.
		- Also do not depend on the data object. Make the method work without any data.
		- Document the fields the data object can have.
	*/
	GetRequiredSize(data := "")
	{
		throw Exception("Abstract method was not overridden.", -1)
	}
}