import re



zero_op={"stc":'f9' , "clc":'f8' , "std":'fd' , "cld":'fc' , "syscall":'0f05' , "ret":'c3'}  # zero operand instructions. ret can have 0 or 1 operand.

registers={"rax":'000' , "rcx":'001' , "rdx":'010' , "rbx":'011' , "rsp":'100' , "rbp":'101' , "rsi":'110' , "rdi": '111' ,
            "eax":'000' , "ecx":'001' , "edx":'010' , "ebx":'011' , "esp":'100' , "ebp":'101' , "esi":'110' , "edi": '111' ,
            "ax":'000' , "cx":'001' , "dx":'010' , "bx":'011' , "sp":'100' , "bp":'101' , "si":'110' , "di": '111' ,
            "al":'000' , "cl":'001' , "dl":'010' , "bl":'011' , "ah":'100' , "ch":'101' , "dh":'110' , "bh": '111' ,
            "r8":'000' , "r9":'001' , "r10":'010' , "r11":'011' , "r12":'100' , "r13":'101' , "r14":'110' , "r15":'111' ,
            "r8d":'000' , "r9d":'001' , "r10d":'010' , "r11d":'011' , "r12d":'100' , "r13d":'101' , "r14d":'110' , "r15d":'111' ,
            "r8w":'000' , "r9w":'001' , "r10w":'010' , "r11w":'011' , "r12w":'100' , "r13w":'101' , "r14w":'110' , "r15w":'111' ,
            "r8b":'000' , "r9b":'001' , "r10b":'010' , "r11b":'011' , "r12b":'100' , "r13b":'101' , "r14b":'110' , "r15b":'111' }

instructions={  
                "mov":['1000100','1000101','1000101','1000100','1100011','1011','1100011','1010000'],

                "add":['0000000','0000001','0000001','0000000','100000','0000010','100000'],
                "adc":['0001000','0001001','0001001','0001000','100000','0001010','100000'],
                "sub":['0010100','0010101','0010101','0010100','100000','0010110','100000'],
                "sbb":['0001100','0001101','0001101','0001100','100000','0001110','100000'],
                "and":['0010000','0010001','0010001','0010000','100000','0010010','100000'],
                "or":['0000100','0000101','0000101','0000100','100000','0000110','100000'],
                "xor":['0011000','0011001','0011001','0011000','100000','0011010','100000'],
                "cmp":['0011100','0011101','0011100','0011101','100000','0011110','100000'],

                "test":['1000010','1000010','1111011','1010100','1111011'],
                "xchg":['1000011','10010','1000011'],
                "xadd":['000011111100000','000011111100000'],

                "imul":['1111011','1111011','0000111110101111','0000111110101111'],
                "idiv":['1111011','1111011'],

              

                "shl":['1101000','1101000','1101001','1101001','1100000','1100000'],
                "shr":['1101000','1101000','1101001','1101001','1100000','1100000'],

                "bsf":['0000111110111100','0000111110111100'],
                "bsr":['0000111110111101','0000111110111101'],

                "jmp":['11101011','11101001','11111111','11111111'],
                "jcc":['0111','000011111000'],
                "jrcxz":['11100011'],
                "call":['11101000','11111111','11111111'],

                "inc":['1111111','1111111'],
                "dec":['1111111','1111111'],
                "neg":['1111011','1111011'],
                "not":['1111011','1111011'],
                "push":['01010','11111111','01101010','01101000'],
                "pop":['01011','10001111']
              }

mod=['00','01','10','11']

hexa={'0':'0000' , '1':'0001' , '2':'0010' , '3':'0011' , '4':'0100' , '5':'0101' , '6':'0110' , '7':'0111' , '8':'1000' , '9':'1001' , 'a':'1010' , 'b':'1011' , 'c':'1100' , 'd':'1101' , 'e':'1110' , 'f':'1111'}

reg_value={"add":'000' , "or":'001' , "adc":'010' , "sub":'011' , "and":'100' , "sub":'101' , "xor":'110' , "cmp":'111'}

byte_size={"BYTE":8 , "WORD":16 , "DWORD":32 , "QWORD":64}    #byte size for register or immediate data

condition={'o':'0000' , 'no':'0001' , 'b':'0010' , 'nae':'0010' , 'nb':'0011' , 'ae':'0011' , 'e':'0100' , 'z':'0100' ,
    'ne':'0101' , 'nz':'0101' , 'be':'0110' , 'na':'0110' , 'nbe':'0111' , 'a':'0111' , 's':'1000' , 'ns':'10001' ,
    'p':'1010' , 'pe':'1010' , 'np':'1011' , 'po':'1011' , 'l':'1100' , 'nge':'1100' , 'nl':'1101' , 'ge':'1101' ,
    'le':'1110' , 'ng':'1110' , 'nle':'1111' , 'g':'1111'
    }

reg_one_op={"inc":'000' , "dec":'001' , "not":'010' , "neg":'011' , "pop":'000' , "push":'110'}

machine_instruction={"prefix":-1,"rex":-1,"opcode":-1,"mod_r/m":-1,"sib":-1,"displacement":-1,"data":-1}

def main():
    string=input()
    string=string.strip()
    l=re.split(',| ',string)
    if len(l)==1:
        print(zero_op[l[0]])
        return
    result=assemble(l)
    print(result)


def assemble(l):
    result=""
    machine_code(l)
    for i in machine_instruction.keys():
        if machine_instruction[i]==-1:
            continue
        # print(i,' : ',machine_instruction[i])
        result+=machine_instruction[i]
    result=hexadecimal(result)
    return result


def machine_code(l):

    if l[0]=="inc":
        one_operand(l)
    elif l[0]=="dec":
        one_operand(l)
    elif l[0]=="neg":
        one_operand(l)
    elif l[0]=="not":
        one_operand(l)
    elif l[0]=="push":
        one_operand(l)
    elif l[0]=="pop":
        one_operand(l)


    if l[0]=="jmp":
        jump(l)
    elif l[0][0]=="j" and l[0][1:] in condition.keys():
        jump(l)
    elif l[0]=="jrcxz":
        jump(l)
    elif l[0]=="call":
        jump(l)

    if l[0]=="ret":         # this is ret with operand
        machine_instruction["opcode"]="11000010"
        machine_instruction["displacement"]=binary(l[1],16,extend=True)


        
    if l[0]=="mov":
        mov(l)

    elif l[0]=="add":
        mov(l)
    elif l[0]=="adc":
        mov(l)
    elif l[0]=="sub":
        mov(l)
    elif l[0]=="sbb":
        mov(l)
    elif l[0]=="and":
        mov(l)
    elif l[0]=="or":
        mov(l)
    elif l[0]=="xor":
        mov(l)
    elif l[0]=="cmp":
        mov(l)


    if l[0]=="test":
        mov(l)
    
    if l[0]=="xchg":
        mov(l)
    
    if l[0]=="xadd":
        mov(l)


    if l[0]=="imul":
        mul_div(l)
    elif l[0]=="idiv":
        mul_div(l)

    if l[0]=="bsf":
        mov(l)
    elif l[0]=="bsr":
        mov(l)
    
    if l[0]=="shr":
        shift(l)
    elif l[0]=="shl":
        shift(l)


def one_operand(l):
    size=len(l)

    reg=reg_one_op[l[0]]

    rex='0100'
    rex_w=r=x=b='0'
    if size==2:     # register

        if number(l[1]):        #push
            if num.isnumeric():
                num=int(num)
                num=hex(num)
            length=len(num)-2
            length*=4
            if length>8:
                machine_instruction["opcode"]=instructions[l[0]][3]
                machine_instruction["data"]=binary(num,32,True)
            else:
                machine_instruction["opcode"]=instructions[l[0]][2]
                machine_instruction["data"]=binary(num,8,True)

            return

        reg_bit=register_size(l[1])
        if new(l[1])=='1' or (reg_bit==64 and l[0]!="pop" and l[0]!="push"):
            if reg_bit==64:
                rex_w='1'
            b=new(l[1])
            machine_instruction["rex"]=rex+rex_w+r+x+b
            
        w=w_bit(reg_bit)

        if l[0]=="push":
            machine_instruction["opcode"]=instructions[l[0]][0]+registers[l[1]]
            pfix=prefix(reg_bit,-1)
            machine_instruction["prefix"]=pfix
            return
        elif l[0]=="pop":
            machine_instruction["opcode"]=instructions[l[0]][0]+registers[l[1]]
            pfix=prefix(reg_bit,-1)
            machine_instruction["prefix"]=pfix
            return
        else:
            machine_instruction["opcode"]=instructions[l[0]][0]+w

        mod="11"
        rm=registers[l[1]]
        machine_instruction["mod_r/m"]=mod+reg+rm
        pfix=prefix(reg_bit,-1)
        machine_instruction["prefix"]=pfix


    else:           #memory
        reg_bit=byte_size[l[1]]
        w=w_bit(reg_bit)
        if l[0]=="push" or l[0]=="pop":
            machine_instruction["opcode"]=instructions[l[0]][1]
            mem_bit=memory(-1,reg,l[3])
        else:
            machine_instruction["opcode"]=instructions[l[0]][1]+w
            mem_bit=memory(reg_bit,reg,l[3])
        pfix=prefix(reg_bit,mem_bit)
        machine_instruction["prefix"]=pfix

def jump(l):
    size=len(l)
    rex="0100"
    rex_w='0'
    r=x=b='0'
    if size==2:             
        if is_register(l[1]):                   # register
            reg_bit=register_size(l[1])
            mod="11"
            if l[0]=="call":
                reg="010"
                machine_instruction["opcode"]=instructions[l[0]][1]
            elif l[0]=="jmp":
                reg="100"
                machine_instruction["opcode"]=instructions[l[0]][2]
            rm=registers[l[1]]
            machine_instruction["mod_r/m"]=mod+reg+rm
            b=new(l[1])
            if b=='1':
                machine_instruction["rex"]=rex+rex_w+r+x+b
            pfix=prefix(reg_bit,-1)
            machine_instruction["prefix"]=pfix
            return

        else:
            if l[0]=="jmp":
                machine_instruction["opcode"]=instructions[l[0]][1]
                machine_instruction["data"]=binary('0x00000000',32,True)
            elif l[0]=="jrcxz":
                machine_instruction["opcode"]=instructions[l[0]][0]
                machine_instruction["data"]=binary('0x00',8,True)
            elif l[0]=="call":
                machine_instruction["opcode"]=instructions[l[0]][0]
                machine_instruction["data"]=binary('0x00000000',32,True)
            else:   #jcc
                cc=condition[l[0][1:]]
                machine_instruction["opcode"]=instructions["jcc"][1]+cc
                machine_instruction["data"]=binary('0x00000000',32,True)
            return


    else:                               # memory
        reg_bit=byte_size[l[1]]
        if l[0]=="call":
            machine_instruction["opcode"]=instructions[l[0]][2]
            reg="010"
        elif l[0]=="jmp":
            machine_instruction["opcode"]=instructions[l[0]][3]
            reg="100"

        if reg_bit==32 and l[0]=="jmp":                 # because somehow DWORD prefix is 66
            reg_bit=16
            reg="101"
        if reg_bit==32 and l[0]=="call":                 # because somehow DWORD prefix is 66
            reg_bit=16
            reg="011"

        mem_bit=memory(reg_bit,reg,l[3])
        pfix=prefix(reg_bit,mem_bit)
        machine_instruction["prefix"]=pfix
        temp=machine_instruction["rex"]
        temp='0100'+'0'+temp[5:]
        machine_instruction["rex"]=temp
        return


def mul_div(l):
    size=len(l)
    if l[0]=="imul":
        reg='101'
    elif l[0]=="idiv":
        reg='111'
    rex='0100'
    rex_w=r=x=b='0'
    if size==2:         # one operand register
        reg_bit=register_size(l[1])
        w=w_bit(reg_bit)
        machine_instruction["opcode"]=instructions[l[0]][0]+w
        mod='11'
        rm=registers[l[1]]
        machine_instruction["mod_r/m"]=mod+reg+rm
        pfix=prefix(reg_bit,-1)
        machine_instruction["prefix"]=pfix
        if reg_bit==64:
            rex_w='1'
            b=new(l[1])
            machine_instruction["rex"]=rex+rex_w+r+x+b
        
    elif size==3:       # two operand registers for imul
        mov(l)

    elif size==4:       # one operand memory for imul and idiv
        reg_bit=byte_size[l[1]]
        w=w_bit(reg_bit)
        machine_instruction["opcode"]=instructions[l[0]][1]+w
        mem_bit=memory(reg_bit,reg,l[3])
        pfix=prefix(reg_bit, mem_bit)
        machine_instruction["prefix"]=pfix

    elif size==5:       # two operand with register memory for imul
        mov(l)


def shift(l):       
    size=len(l)
    rex="0100"
    rex_w=r=x=b='0'
    if l[0]=="shl":
        reg="100"
    elif l[0]=="shr":
        reg="101"

    if size==3 or size==2:
        if size==2:
            l.append('1')
        reg_bit=register_size(l[1])
        w=w_bit(reg_bit)

        mod="11"
        rm=registers[l[1]]
        if l[2]=='1':
            machine_instruction["opcode"]=instructions[l[0]][0]+w
                

        elif l[2]=='cl':
            machine_instruction["opcode"]=instructions[l[0]][2]+w
            
        else:
            machine_instruction["opcode"]=instructions[l[0]][4]+w
            machine_instruction["data"]=binary(l[2],8,True)

        machine_instruction["mod_r/m"]=mod+reg+rm
        pfix=prefix(reg_bit,-1)
        machine_instruction["prefix"]=pfix

        if reg_bit==64 or new(l[1])=='1':
            if reg_bit==64:
                rex_w='1'
            if new(l[1])=='1':
                b='1'
            machine_instruction["rex"]=rex+rex_w+r+x+b

    else:
        if size==4:
            l.append('1')
        reg_bit=byte_size[l[1]]
        w=w_bit(reg_bit)


        if l[4]=='1':
            machine_instruction["opcode"]=instructions[l[0]][1]+w


        elif l[4]=='cl':
            machine_instruction["opcode"]=instructions[l[0]][3]+w


        else:
            machine_instruction["opcode"]=instructions[l[0]][5]+w
            machine_instruction["data"]=binary(l[4],8,True)


        mem_bit=memory(reg_bit,reg,l[3])
        pfix=prefix(reg_bit,mem_bit)
        machine_instruction["prefix"]=pfix


def mov(l):
    size=len(l)
    mod=reg=rm=""
    mod_rm=opcode=data=-1
    rex="0100"
    rex_w=r=x=b='0'                                  # for rex byte. rex_w is rex.w
    is_rex=False
    if size==3:
        reg_bit=register_size(l[1])
        w=w_bit(reg_bit)
        mod="11"
        if new(l[1])=='1' or new(l[2])=='1' or reg_bit==64:
            is_rex=True

        if number(l[2]):

            if is_rex:
                if reg_bit==64:
                    rex_w='1'
                b=new(l[1])
                machine_instruction["rex"]=rex+rex_w+r+x+b

            if l[0]=="mov":
                if reg_bit==64:
                    opcode=instructions[l[0]][4]+w
                    mod_rm=mod+"000"+registers[l[1]]
                else:
                    opcode=instructions[l[0]][5]+w+registers[l[1]]
                if reg_bit==64:
                    reg_bit=32                                  # ??
                data=binary(l[2],reg_bit,extend=True)

            elif l[0]=="test":
                if l[1]=="al" or l[1]=="ax" or l[1]=="eax" or l[1]=="rax":
                    opcode=instructions[l[0]][3]+w
                else:
                    opcode=instructions[l[0]][2]+w
                    mod_rm=mod+"000"+registers[l[1]]
                data=binary(l[2],reg_bit,True)

            else:   # add adc sub sbb and or xor cmp

                if accum(l[1]):
                    bit,code=extension(l[1],l[2])
                    if code==5:
                        opcode=instructions[l[0]][5]+w
                    else:
                        s,bit=s_bit(reg_bit,l[2])
                        opcode=instructions[l[0]][4]+s+w
                        reg=reg_value[l[0]]
                        mod_rm=mod+reg+registers[l[1]]
                    data=binary(l[2],bit,extend=True)

                else:
                    s,bit=s_bit(reg_bit,l[2])
                    opcode=instructions[l[0]][4]+s+w
                    reg=reg_value[l[0]]
                    mod_rm=mod+reg+registers[l[1]]
                    data=binary(l[2],bit,extend=True)

    

        else:
            if is_rex:
                if reg_bit==64:
                    rex_w='1'
                if l[0]=="imul":
                    r=new(l[1])
                    b=new(l[2])
                else:
                    r=new(l[2])
                    b=new(l[1])
                machine_instruction["rex"]=rex+rex_w+r+x+b

            if l[0]=="bsf" or l[0]=="bsr":
                opcode=instructions[l[0]][0]
                mod_rm=mod+registers[l[1]]+registers[l[2]]
            elif l[0]=="imul":
                opcode=instructions[l[0]][2]
                mod_rm=mod+registers[l[1]]+registers[l[2]]
            elif l[0]=="xchg":
                if l[1]=="ax" or l[1]=="eax" or l[1]=="rax":
                    opcode=instructions[l[0]][1]+registers[l[2]]                    ### rex byte is wroooong.
                else:
                    opcode=instructions[l[0]][0]+w
                    mod_rm=mod+registers[l[2]]+registers[l[1]]
            else:
                opcode=instructions[l[0]][0]+w
                mod_rm=mod+registers[l[2]]+registers[l[1]]

            
        pfix=prefix(reg_bit,-1)
        machine_instruction["prefix"]=pfix
        machine_instruction["mod_r/m"]=mod_rm
        machine_instruction["opcode"]=opcode
        machine_instruction["data"]=data

    else:
        if l[2]=="PTR":                                             # reg to memory or immediate to memory
            
            if number(l[4]):                                        #immediate to memory
                reg_bit=byte_size[l[1]]
                w=w_bit(reg_bit)

                if l[0]=="mov":
                    machine_instruction["opcode"]=instructions[l[0]][6]+w
                    reg='000'
                    bit=reg_bit
                elif l[0]=="test":
                    machine_instruction["opcode"]=instructions[l[0]][4]+w
                    reg='000'
                    bit=reg_bit
                else:
                    s,bit=s_bit(reg_bit,l[4])
                    machine_instruction["opcode"]=instructions[l[0]][6]+s+w
                    reg=reg_value[l[0]]

                machine_instruction["data"]=binary(l[4],bit,True)
                mem_bit=memory(reg_bit,reg,l[3])
                pfix=prefix(reg_bit, mem_bit)
                machine_instruction["prefix"]=pfix
            else:                                                   #register to memory
                reg_bit=byte_size[l[1]]
                w=w_bit(reg_bit)
                reg=registers[l[4]]
                if l[0]=="mov":
                    machine_instruction["opcode"]=instructions[l[0]][3]+w
                elif l[0]=="xchg":
                    machine_instruction["opcode"]=instructions[l[0]][2]+w
                elif l[0]=="test":
                    machine_instruction["opcode"]=instructions[l[0]][1]+w
                elif l[0]=="xadd":
                    machine_instruction["opcode"]=instructions[l[0]][1]+w
                else:
                    machine_instruction["opcode"]=instructions[l[0]][3]+w
                mem_bit=memory(reg_bit,reg,l[3])

                if new(l[4])=="1":                           # this is for R bit in rex
                    temp=machine_instruction["rex"]
                    temp=temp[0:5]+"1"+temp[6:]
                    machine_instruction["rex"]=temp

                pfix=prefix(reg_bit, mem_bit)
                machine_instruction["prefix"]=pfix

        elif l[3]=="PTR":                                           # memory to reg
            reg_bit=register_size(l[1])
            mem_bit=-1
            w=w_bit(reg_bit)
            if l[0]=="bsr" or l[0]=="bsf":
                opcode=instructions[l[0]][1]
            elif l[0]=="imul":
                opcode=instructions[l[0]][3]
            elif l[0]=="xchg":
                opcode=instructions[l[0]][2]+w
            elif l[0]=="test":
                opcode=instructions[l[0]][1]+w
            else:                                        
                opcode=instructions[l[0]][2]+w
            reg=registers[l[1]]
            mem_bit=memory(reg_bit,reg,l[4])

            if new(l[1])=='1':
                temp=machine_instruction["rex"]
                temp=temp[0:5]+"1"+temp[6:]
                machine_instruction["rex"]=temp

            pfix=prefix(reg_bit,mem_bit)
            machine_instruction["prefix"]=pfix
            machine_instruction["opcode"]=opcode
            




def memory(reg_bit,reg,string):
    is_rex=False
    rex='0100'
    rex_w=r=x=b='0'
    if reg_bit==64:
        rex_w='1'
        is_rex=True

    string=string[1:-1]
    exp=re.split('\+|\*',string)    #splits string to [base,index,scale,displacement]
    size=len(exp)
    mod=rm=""
    if size==1:
        if number(exp[0]):          # direct addressing uses sib
            mod="00"
            rm="100"
            machine_instruction["mod_r/m"]=mod+reg+rm
            scale="00"
            index="100"
            base="101"
            machine_instruction["sib"]=scale+index+base
            machine_instruction["displacement"]=binary(exp[0],32,True)      #???
            mem_bit=-1
        else:
            if exp[0]=="ebp":
                mod="01"
                machine_instruction["displacement"]=binary('0x00',8,True)
            else:
                mod="00"

            if new(exp[0])=='1':
                is_rex=True
                b=new(exp[0])
            
            rm=registers[exp[0]]
            machine_instruction["mod_r/m"]=mod+reg+rm
            mem_bit=register_size(exp[0])
            
        if is_rex:
            machine_instruction["rex"]=rex+rex_w+r+x+b

        return mem_bit

    elif size==2:
        if exp[1][0:2]=='0x':               # base displacement
            mod,reg_bit=disp(exp[1])
            rm=registers[exp[0]]
            machine_instruction["mod_r/m"]=mod+reg+rm
            machine_instruction["displacement"]=binary(exp[1],reg_bit,True)
            mem_bit=register_size(exp[0])

            if new(exp[0])=='1':
                is_rex=True
                b=new(exp[0])

        elif exp[1].isnumeric():            # this is sib. index scale                                
            mod="00"
            rm="100"
            machine_instruction["mod_r/m"]=mod+reg+rm
            scale=get_scale(exp[1])
            index=registers[exp[0]]
            base="101"
            machine_instruction["sib"]=scale+index+base
            machine_instruction["displacement"]=binary("0x00000000",32,True)
            mem_bit=register_size(exp[0])

            if new(exp[0])=='1':
                is_rex=True
                x=new(exp[0])

        else:                               #this is sib. base index
            mod="00"
            rm="100"
            machine_instruction["mod_r/m"]=mod+reg+rm
            scale="00"
            index=registers[exp[1]]
            base=registers[exp[0]]
            machine_instruction["sib"]=scale+index+base
            mem_bit=register_size(exp[0])

            if new(exp[0])=='1':
                is_rex=True
                b=new(exp[0])
            if new(exp[1])=='1':
                is_rex=True
                x=new(exp[1])

        if is_rex:
            machine_instruction["rex"]=rex+rex_w+r+x+b

        return mem_bit

    elif size==3:
        if exp[2][0:2]=='0x':           # third item is displacement
            if exp[1].isnumeric():      #we have index scale displacement
                mod="00"
                rm="100"
                machine_instruction["mod_r/m"]=mod+reg+rm
                scale=get_scale(exp[1])
                index=registers[exp[0]]
                base="101"
                machine_instruction["sib"]=scale+index+base
                machine_instruction["displacement"]=binary(exp[2],32,True)
                mem_bit=register_size(exp[0])

                if new(exp[0])=='1':
                    is_rex=True
                    x='1'


            else:                       # we have base index displacement
                mod,reg_bit=disp(exp[2])
                rm="100"
                machine_instruction["mod_r/m"]=mod+reg+rm
                scale="00"
                index=registers[exp[1]]
                base=registers[exp[0]]
                machine_instruction["sib"]=scale+index+base
                machine_instruction["displacement"]=binary(exp[2],reg_bit,True)
                mem_bit=register_size(exp[0])

                if new(exp[0])=='1':
                    is_rex=True
                    b='1'
                if new(exp[1])=='1':
                    is_rex=True
                    x='1'

        else:                       #third item is scale
            if exp[0]=="ebp":
                mod="01"
                machine_instruction["displacement"]=binary("0x00",8,True)
            else:
                mod="00"
            rm="100"
            machine_instruction["mod_r/m"]=mod+reg+rm
            scale=get_scale(exp[2])
            index=registers[exp[1]]
            base=registers[exp[0]]
            machine_instruction["sib"]=scale+index+base
            mem_bit=register_size(exp[0])

            if new(exp[0])=='1':
                is_rex=True
                b='1'
            if new(exp[1])=='1':
                is_rex=True
                x='1'

        if is_rex:
            machine_instruction["rex"]=rex+rex_w+r+x+b

        return mem_bit

    elif size==4:
        mod,reg_bit=disp(exp[3])
        rm="100"
        machine_instruction["mod_r/m"]=mod+reg+rm
        scale=get_scale(exp[2])
        index=registers[exp[1]]
        base=registers[exp[0]]
        machine_instruction["sib"]=scale+index+base
        machine_instruction["displacement"]=binary(exp[3],reg_bit,True)
        mem_bit=register_size(exp[0])

        if new(exp[0])=='1':
            is_rex=True
            b='1'
        if new(exp[1])=='1':
            is_rex=True
            x='1'

        if is_rex:
            machine_instruction["rex"]=rex+rex_w+r+x+b

        return mem_bit


def new(r):                     #checks if register r is new (r8 or r15d) or its old(rax or dx)
    if r[0]=='r' and ( r[-1]=='d' or r[-1]=='w' or r[-1]=='b' or r[1:].isnumeric()):
        return '1'
    else:
        return '0'

def s_bit(reg_bit,num):
    if num[0:2]=='0x':
        decimal=int(num,16)
    else:
        decimal=int(num)

    if decimal<=127 and (reg_bit==16 or reg_bit==32 or reg_bit==64 ):
        s='1'
        bit=8
    elif decimal>=128 and (reg_bit==16 or reg_bit==32 or reg_bit==64 ):
        s='0'
        bit=reg_bit
        if bit==64:
            bit=32
    else:
        s='0'
        bit=8
    return s,bit



def extension(r,num):
    reg_bit=register_size(r)
    if num[0:2]=='0x':
        decimal=int(num,16)
    else:
        decimal=int(num)

    if reg_bit==8:
        bit=8
        if r=="al":
            code=5
        elif r=="ah":
            code=4
    else:
        if decimal<=127:
            code=4
            bit=8
        elif decimal>=128:
            code=5
            bit=reg_bit
            if bit==64:
                bit=32
    return bit,code
        


def is_register(r):
    if r in registers.keys():
        return True
    else:
        return False

def get_scale(scale):
    scale=int(scale)
    if scale==1:
        return "00"
    elif scale==2:
        return "01"
    elif scale==4:
        return "10"
    elif scale==8:
        return "11"

def disp(num):              #displacement must be hex.
    decimal=int(num,16)
    if decimal<128:
        return "01",8
    else:
        return "10",32

def accum(r):
    if r=="al" or r=="ah" or r=="ax" or r=="eax" or r=="rax":
        return True
    else:
        return False


def prefix(reg_bit,mem_bit):                # if operand size 16 bit then add 66. if address size 32bit then add 67. first 67 then 66
    result=""

    if mem_bit==32:
        result+="01100111"                  #67
    if reg_bit==16:
        result+="01100110"                  #66

    if result=="":
        return -1
    return result

def hexadecimal(bin):       # converts binary string to hexadecimal string without 0x prefix
    result=""
    i=4
    while(i<=len(bin)):
        temp=bin[i-4:i]
        for key,value in hexa.items():
            if temp==value:
                result+=key
        i+=4
    return result

def binary(num,reg_bit,extend):
    if reg_bit==64:
        reg_bit=32

    if num.isnumeric():
        num=int(num)
        num=hex(num)
    result=""
    reg_bit=int(reg_bit/4)
    zero=reg_bit-len(num)+2
    num=num[2:]
    if len(num)>reg_bit:
        temp=len(num)-reg_bit
        num=num[temp:]
    if extend:
        for i in range(zero):
            num='0'+num
    i=len(num)-1
    while(i>=1):
        result+=hexa[num[i-1]] + hexa[num[i]]
        i-=2
    return result



def register_size(r):
    if r[0]=='r' and r[1:].isnumeric():
        return 64
    elif r[0]=='r' and r[-1]!='d' and r[-1]!='w' and r[-1]!='b':
        return 64
    elif r[0]=='e' or r[-1]=='d':
        return 32
    elif r[1]=='x' or r[1]=='p' or r[1]=='i' or r[-1]=='w':
        return 16
    elif r[1]=='l' or r[1]=='h' or r[-1]=='b':
        return 8

def w_bit(reg_bit):
    if reg_bit ==64 or reg_bit==32 or reg_bit==16:
        return '1'
    elif reg_bit==8:
        return '0'

def number(string):
    if string[0:2]=='0x':
        return True
    elif string.isnumeric():
        return True
    else:
        return False


if __name__=="__main__":
    main()