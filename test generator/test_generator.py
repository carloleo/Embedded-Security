import bitarray
from bitarray import *
from bitarray.util import *


def newh():
    H = [int2ba(0x4, 4), int2ba(0xB, 4), int2ba(0x7, 4), int2ba(0x1, 4), int2ba(0xD, 4),
         int2ba(0xF, 4), int2ba(0x0, 4), int2ba(0x3, 4)]
    return H


S_box = {
    '000000': '0010',
    '000001': '1110',
    '100000': '0100',
    '100001': '1011',
    '000010': '1100',
    '000011': '1011',
    '100010': '0010',
    '100011': '1000',
    '000100': '0100',
    '000101': '0010',
    '100100': '0001',
    '100101': '1100',
    '000110': '0001',
    '000111': '1100',
    '100110': '1011',
    '100111': '0111',
    '001000': '0111',
    '001001': '0100',
    '101000': '1100',
    '101001': '0001',
    '001010': '1010',
    '001011': '0111',
    '101010': '1101',
    '101011': '1110',
    '001100': '1011',
    '001101': '1101',
    '101100': '0111',
    '101101': '0010',
    '001110': '0110',
    '001111': '0001',
    '101110': '1000',
    '101111': '1101',
    '010000': '1000',
    '010001': '0101',
    '110000': '1111',
    '110001': '0110',
    '010010': '0101',
    '010011': '0000',
    '110010': '1001',
    '110011': '1111',
    '010100': '0011',
    '010101': '1111',
    '110100': '1100',
    '110101': '0000',
    '010110': '1111',
    '010111': '1100',
    '110110': '0101',
    '110111': '1001',
    '011000': '1101',
    '011001': '0011',
    '111000': '0110',
    '111001': '1100',
    '011010': '0000',
    '011011': '1001',
    '111010': '0011',
    '111011': '0100',
    '011100': '1110',
    '011101': '1000',
    '111100': '0000',
    '111101': '0101',
    '011110': '1001',
    '011111': '0110',
    '111110': '1110',
    '111111': '0011',
}
def cshift(v, n):
    rs = 4 - n
    return (v << n) | (v >> rs)

def S(i):
    return bitarray(S_box[i.to01()])


def main_round(M, H):
    M = int2ba(M, 8)
    M6 = bitarray([M[3] ^ M[2], M[1], M[0], M[7], M[6], M[5] ^ M[4]])

    H1 = list.copy(H)
    for r in range(0, 4):
        for i in range(0, 8):
            H1[i] = cshift(H[(i + 1) % 8] ^ S(M6), i // 2)
        H = list.copy(H1)
    return H


def final_round(C, H):
    H1 = list.copy(H)
    C = [(C >> i * 8) % 256 for i in range(0, 8)]
    C = [int2ba(c, 8) for c in C]
    for i in range(0, 8):
        C6 = bitarray([C[i][7] ^ C[i][1], C[i][3], C[i][2], C[i][5] ^ C[i][0], C[i][4], C[i][6]])
        H1[i] = cshift(H[(i + 1) % 8] ^ S(C6), i//2)
    return H1


def full_hash(message):
    H = newh()
    for M in message:
        H = main_round(M, H)
    C = len(message)
    return final_round(C, H)

def string_to_hash(message):
    message = [ord(c) for c in message]
    return full_hash(message)

def digest_to_hex(digest):
    tmp = bitarray()
    for a in digest:
        tmp.extend(a)
    return ba2hex(tmp)

final_round(231231, newh())