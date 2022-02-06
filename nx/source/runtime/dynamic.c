#include "result.h"
#include "runtime/diag.h"
#include <elf.h>

#ifdef __ARM_ARCH_ISA_A64
void __nx_dynamic(uintptr_t base, const Elf64_Dyn* dyn)
{
	const Elf64_Rela* rela = NULL;
	u64 relasz = 0;

	for (; dyn->d_tag != DT_NULL; dyn++)
	{
		switch (dyn->d_tag)
		{
			case DT_RELA:
				rela = (const Elf64_Rela*)(base + dyn->d_un.d_ptr);
				break;
			case DT_RELASZ:
				relasz = dyn->d_un.d_val / sizeof(Elf64_Rela);
				break;
		}
	}

	if (rela == NULL)
		diagAbortWithResult(MAKERESULT(Module_Libnx, LibnxError_BadReloc));

	for (; relasz--; rela++)
	{
		switch (ELF64_R_TYPE(rela->r_info))
		{
			case R_AARCH64_RELATIVE:
			{
				u64* ptr = (u64*)(base + rela->r_offset);
				*ptr = base + rela->r_addend;
				break;
			}
		}
	}
}
#else
void __nx_dynamic(uintptr_t base, const Elf32_Dyn* dyn)
{
	const Elf32_Rela* rela = NULL;
	const Elf32_Rel* rel = NULL;
	u32 relasz = 0;
	u32 relsz = 0;

	for (; dyn->d_tag != DT_NULL; dyn++)
	{
		switch (dyn->d_tag)
		{
			case DT_RELA:
				rela = (const Elf32_Rela*)(base + dyn->d_un.d_ptr);
				break;
			case DT_RELASZ:
				relasz = dyn->d_un.d_val / sizeof(Elf32_Rela);
				break;
			case DT_REL:
				rel = (const Elf32_Rel*)(base + dyn->d_un.d_ptr);
				break;
			case DT_RELSZ:
				relsz = dyn->d_un.d_val / sizeof(Elf32_Rel);
				break;
		}
	}

	if ((rela == NULL) && (rel == NULL))
		diagAbortWithResult(MAKERESULT(Module_Libnx, LibnxError_BadReloc));

	for (; relasz--; rela++)
	{
		switch (ELF32_R_TYPE(rela->r_info))
		{
			case R_ARM_RELATIVE:
			{
				u32* ptr = (u32*)(base + rela->r_offset);
				*ptr = base + rela->r_addend;
				break;
			}
		}
	}

	for (; relsz--; rel++)
	{
		switch (ELF32_R_TYPE(rel->r_info))
		{
			case R_ARM_RELATIVE:
			{
				u32* ptr = (u32*)(base + rel->r_offset);
				*ptr += base;
				break;
			}
		}
	}
}
#endif
