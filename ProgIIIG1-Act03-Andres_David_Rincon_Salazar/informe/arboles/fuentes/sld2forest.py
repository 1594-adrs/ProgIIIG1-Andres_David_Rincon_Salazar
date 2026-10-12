"""Convert the LaTeX (ecltree) output of SLDNF Draw into a `forest` tree.

ecltree overlaps wide labels in deep trees; forest computes the layout from
the real width of every node. Bindings are written inside the child node,
above its resolvent, so their width is reserved too. Only the drawing
changes: nodes, edges, bindings and leaves are taken verbatim from the
SLDNF Draw output.

The tree can be cut at a given number of levels (the cut nodes become a
"..." leaf); cutting here instead of with set_depth/1 keeps the terms whole,
because SLDNF Draw also abbreviates terms deeper than its depth limit.

usage: python sld2forest.py in.tex out.tex [levels]
"""
import re
import sys


class Node:
    def __init__(self, label, boxed=None):
        self.label = label      # LaTeX text, or None when boxed is used
        self.boxed = boxed      # Node drawn inside a frame (negation)
        self.children = []      # list of (binding, Node)


class Parser:
    def __init__(self, s):
        self.s = s
        self.i = 0

    def ws(self):
        while self.i < len(self.s) and self.s[self.i].isspace():
            self.i += 1

    def expect(self, tok):
        self.ws()
        assert self.s.startswith(tok, self.i), (tok, self.s[self.i:self.i + 80])
        self.i += len(tok)

    def balanced(self, open_='{', close='}'):
        """Read from just after an opening delimiter to its match."""
        depth, start = 1, self.i
        while depth:
            c = self.s[self.i]
            if c == '\\':
                self.i += 2
                continue
            if c == open_:
                depth += 1
            elif c == close:
                depth -= 1
            self.i += 1
        return self.s[start:self.i - 1]

    def bundle(self):
        self.expect('\\begin{bundle}{')
        self.ws()
        if self.s.startswith('\\framebox{', self.i):
            self.i += len('\\framebox{')
            inner = self.bundle()
            self.expect('}}')
            node = Node(None, boxed=inner)
        else:
            node = Node(self.balanced())
        while True:
            self.ws()
            if self.s.startswith('\\end{bundle}', self.i):
                self.i += len('\\end{bundle}')
                return node
            node.children.append(self.chunk())

    def chunk(self):
        self.expect('\\chunk')
        binding = ''
        if self.s[self.i] == '[':
            self.i += 1
            binding = self.balanced('[', ']')
        self.expect('{')
        self.ws()
        if self.s.startswith('\\begin{bundle}', self.i):
            child = self.bundle()
            self.expect('}')
        else:
            child = Node(self.balanced().replace('~', '').strip())
        return binding.strip(), child


def label_text(label):
    m = re.fullmatch(r'\\begin\{tabular\}\{c\}(.*)\\end\{tabular\}', label, re.S)
    return m.group(1) if m else label


LEAF_STYLE = {'true': 'exito', 'false': 'fallo', '...': 'corte'}


def emit(node, out, levels, depth=0, binding=''):
    pad = '  ' * depth
    opts = []
    if node.boxed is not None:
        # negation as failure: the framed sub-derivation is one boxed node
        inner = node.boxed
        res = ' / '.join(c.label for _, c in inner.children) or 'false'
        text = label_text(inner.label) + r'\\$\Rightarrow$ ' + res
        opts.append('negacion')
    else:
        text = label_text(node.label)
        if not node.children and text in LEAF_STYLE:
            opts.append(LEAF_STYLE[text])
            text = {'...': r'$\cdots$'}.get(text, text)
    if binding:
        # the binding goes inside the child node so forest reserves its width
        text = r'\ligadura{%s}\\' % binding + text
    out.append('%s[{%s}%s' % (pad, text, (', ' + ', '.join(opts)) if opts else ''))
    cut = depth + 1 >= levels
    for b, child in node.children:
        if cut and child.children:
            # deeper subtree is not drawn; leaves (true/false) still are
            out.append(r'%s  [{$\cdots$}, corte]' % pad)
        else:
            emit(child, out, levels, depth + 1, b)
    out.append(pad + ']')


def main(src, dst, levels=10**9):
    s = open(src, encoding='utf-8').read()
    s = re.sub(r'^%.*$', '', s, flags=re.M)
    p = Parser(s)
    root = p.bundle()
    out = []
    emit(root, out, levels)
    open(dst, 'w', encoding='utf-8').write('\\begin{forest} arbolsld\n' + '\n'.join(out) + '\n\\end{forest}\n')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], *map(int, sys.argv[3:]))
